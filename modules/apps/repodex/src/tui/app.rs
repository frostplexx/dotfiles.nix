use std::fmt::format;
use std::io;
use std::path::PathBuf;
use std::process::Command;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

use super::repo_info::RepoInfo;
use crate::features::list as repo_list;
use crate::AppContext;
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyModifiers};
use nucleo_matcher::pattern::{AtomKind, CaseMatching, Normalization, Pattern};
use nucleo_matcher::{Config, Matcher, Utf32Str};
use ratatui::layout::{Alignment, Constraint, Layout, Margin, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{
    Block, BorderType, Borders, List, ListItem, ListState, Padding, Paragraph, Scrollbar,
    ScrollbarOrientation, ScrollbarState,
};
use ratatui::{DefaultTerminal, Frame};
use std::os::unix::process::CommandExt;

// ── Terminal‑native colour aliases ──────────────────────────────────────────
// Using the "bright" ANSI variants where possible for better contrast on
// both dark and light terminals.

const C_TEXT: Color = Color::White;
const C_TEXT_DIM: Color = Color::Gray;
const C_TEXT_MUTED: Color = Color::DarkGray;
const C_BORDER: Color = Color::Gray;
const C_BORDER_FOCUS: Color = Color::LightBlue;
const C_ACCENT: Color = Color::LightBlue;
const C_HIGHLIGHT_BG: Color = Color::DarkGray;
const C_GREEN: Color = Color::LightGreen;
const C_RED: Color = Color::LightRed;
const C_YELLOW: Color = Color::LightYellow;
const C_CYAN: Color = Color::LightCyan;
const C_ORANGE: Color = Color::Yellow;

// ── Repo entry ──────────────────────────────────────────────────────────────

#[derive(Debug)]
struct RepoEntry {
    full_path: PathBuf,
    root: PathBuf,
    relative: String,
}

// ── Match result from fuzzy search ──────────────────────────────────────────

struct MatchResult {
    index: usize,
    score: u32,
    match_positions: Vec<u32>,
}

// ── Background preview handle ───────────────────────────────────────────────

struct PreviewHandle {
    /// Set to true to tell the worker to stop early.
    cancel: Arc<AtomicBool>,
    /// The worker writes its result here when done.
    result: Arc<Mutex<Option<RepoInfo>>>,
}

// ── Application state ───────────────────────────────────────────────────────

struct AppState {
    repos: Vec<RepoEntry>,
    filtered: Vec<MatchResult>,
    query: String,
    list_state: ListState,
    /// The currently-displayed preview (may lag behind selection).
    preview: Option<RepoInfo>,
    /// Handle for the in-flight background preview job.
    preview_handle: Option<PreviewHandle>,
    matcher: Matcher,
    should_quit: bool,
    selected_path: Option<PathBuf>,
    error_msg: Option<String>,
}

impl AppState {
    fn new(ctx: &AppContext) -> Self {
        let all = repo_list::discover_all_repos(ctx);
        let repos: Vec<RepoEntry> = all
            .into_iter()
            .map(|(root, full)| {
                let relative = full
                    .strip_prefix(&root)
                    .unwrap_or(&full)
                    .to_string_lossy()
                    .to_string();
                RepoEntry {
                    full_path: full,
                    root,
                    relative,
                }
            })
            .collect();

        let filtered: Vec<MatchResult> = repos
            .iter()
            .enumerate()
            .map(|(i, _)| MatchResult {
                index: i,
                score: 0,
                match_positions: Vec::new(),
            })
            .collect();

        let initial_select = if filtered.is_empty() { None } else { Some(0) };

        let mut state = AppState {
            repos,
            filtered,
            query: String::new(),
            list_state: ListState::default().with_selected(initial_select),
            preview: None,
            preview_handle: None,
            matcher: Matcher::new(Config::DEFAULT),
            should_quit: false,
            selected_path: None,
            error_msg: None,
        };

        state.request_preview();
        state
    }

    fn refilter(&mut self) {
        if self.query.is_empty() {
            self.filtered = self
                .repos
                .iter()
                .enumerate()
                .map(|(i, _)| MatchResult {
                    index: i,
                    score: 0,
                    match_positions: Vec::new(),
                })
                .collect();
        } else {
            let pattern = Pattern::new(
                &self.query,
                CaseMatching::Smart,
                Normalization::Smart,
                AtomKind::Fuzzy,
            );

            let mut results: Vec<MatchResult> = Vec::new();
            let mut buf = Vec::new();

            for (i, repo) in self.repos.iter().enumerate() {
                let haystack = Utf32Str::new(&repo.relative, &mut buf);
                let mut indices = Vec::new();
                if let Some(score) = pattern.indices(haystack, &mut self.matcher, &mut indices) {
                    results.push(MatchResult {
                        index: i,
                        score,
                        match_positions: indices,
                    });
                }
            }

            results.sort_by(|a, b| b.score.cmp(&a.score));
            self.filtered = results;
        }

        if self.filtered.is_empty() {
            self.list_state.select(None);
        } else {
            self.list_state.select(Some(0));
        }

        self.request_preview();
    }

    fn selected_repo(&self) -> Option<&RepoEntry> {
        let sel = self.list_state.selected()?;
        let m = self.filtered.get(sel)?;
        self.repos.get(m.index)
    }

    /// Cancel any in-flight preview and spawn a new background job for the
    /// currently-selected repo.  The result is polled in the main loop.
    fn request_preview(&mut self) {
        // Cancel previous job
        if let Some(handle) = self.preview_handle.take() {
            handle.cancel.store(true, Ordering::Relaxed);
        }

        let repo = match self.selected_repo() {
            Some(r) => r,
            None => {
                self.preview = None;
                return;
            }
        };

        let full_path = repo.full_path.clone();
        let root = repo.root.clone();

        let cancel = Arc::new(AtomicBool::new(false));
        let result: Arc<Mutex<Option<RepoInfo>>> = Arc::new(Mutex::new(None));

        let cancel_clone = Arc::clone(&cancel);
        let result_clone = Arc::clone(&result);

        thread::spawn(move || {
            let info = RepoInfo::collect(&full_path, &root, &cancel_clone);
            // Only write the result if we weren't cancelled
            if !cancel_clone.load(Ordering::Relaxed) {
                if let Ok(mut guard) = result_clone.lock() {
                    *guard = Some(info);
                }
            }
        });

        self.preview_handle = Some(PreviewHandle { cancel, result });
    }

    /// Check if the background preview job has finished and, if so, take
    /// the result.  Called once per frame — very cheap.
    fn poll_preview(&mut self) {
        let handle = match &self.preview_handle {
            Some(h) => h,
            None => return,
        };

        let ready = handle
            .result
            .lock()
            .map(|guard| guard.is_some())
            .unwrap_or(false);

        if ready {
            if let Some(handle) = self.preview_handle.take() {
                if let Ok(mut guard) = handle.result.lock() {
                    self.preview = guard.take();
                }
            }
        }
    }

    fn move_selection(&mut self, delta: i32) {
        if self.filtered.is_empty() {
            return;
        }
        let len = self.filtered.len() as i32;
        let current = self.list_state.selected().unwrap_or(0) as i32;
        let next = (current + delta).clamp(0, len - 1) as usize;
        self.list_state.select(Some(next));
        self.request_preview();
    }

    fn page_size(&self, area_height: u16) -> i32 {
        (area_height.saturating_sub(2) as i32).max(1)
    }
}

// ── Main loop ───────────────────────────────────────────────────────────────

pub fn app(ctx: &AppContext, terminal: &mut DefaultTerminal) -> io::Result<()> {
    let mut state = AppState::new(ctx);
    let mut list_area_height: u16 = 20;

    loop {
        // Check for finished preview work
        state.poll_preview();

        terminal.draw(|f| {
            let h = render(f, &state);
            list_area_height = h;
        })?;

        if state.should_quit {
            break;
        }

        // Poll events with a short timeout so we can keep polling the
        // preview thread without blocking forever.
        if event::poll(Duration::from_millis(50))? {
            match event::read() {
                Ok(Event::Key(key)) => handle_key(&mut state, key, list_area_height, ctx),
                Ok(_) => {}
                Err(e) => {
                    state.error_msg = Some(format!("input error: {e}"));
                }
            }
        }
    }

    // Cancel any lingering background work
    if let Some(handle) = state.preview_handle.take() {
        handle.cancel.store(true, Ordering::Relaxed);
    }

    if let Some(path) = &state.selected_path {
        println!("cd {}", path.display());
    }

    Ok(())
}

fn handle_key(state: &mut AppState, key: KeyEvent, list_height: u16, ctx: &AppContext) {
    state.error_msg = None;

    match key.code {
        KeyCode::Esc | KeyCode::Char('c')
            if key.code == KeyCode::Esc || key.modifiers.contains(KeyModifiers::CONTROL) =>
        {
            if !state.query.is_empty() && key.code == KeyCode::Esc {
                state.query.clear();
                state.refilter();
            } else {
                state.should_quit = true;
            }
        }
        KeyCode::Enter => {
            if let Some(repo) = state.selected_repo() {
                state.selected_path = Some(repo.full_path.clone());
                state.should_quit = true;
            }
        }
        KeyCode::Down | KeyCode::Tab => state.move_selection(1),
        KeyCode::Up | KeyCode::BackTab => state.move_selection(-1),
        KeyCode::Char('n') if key.modifiers.contains(KeyModifiers::CONTROL) => {
            state.move_selection(1);
        }
        KeyCode::Char('p') if key.modifiers.contains(KeyModifiers::CONTROL) => {
            state.move_selection(-1);
        }
        KeyCode::Char('d') if key.modifiers.contains(KeyModifiers::CONTROL) => {
            let half = state.page_size(list_height) / 2;
            state.move_selection(half);
        }
        KeyCode::Char('u') if key.modifiers.contains(KeyModifiers::CONTROL) => {
            let half = state.page_size(list_height) / 2;
            state.move_selection(-half);
        }
        KeyCode::Char('w') if key.modifiers.contains(KeyModifiers::CONTROL) => {
            let trimmed = state.query.trim_end();
            if let Some(pos) = trimmed.rfind(|c: char| c == '/' || c == ' ') {
                state.query.truncate(pos);
            } else {
                state.query.clear();
            }
            state.refilter();
        }
        KeyCode::Home => {
            if !state.filtered.is_empty() {
                state.list_state.select(Some(0));
                state.request_preview();
            }
        }
        KeyCode::End => {
            if !state.filtered.is_empty() {
                state.list_state.select(Some(state.filtered.len() - 1));
                state.request_preview();
            }
        }
        KeyCode::Backspace => {
            if !state.query.is_empty() {
                state.query.pop();
                state.refilter();
            }
        }
        KeyCode::Char(c) if !key.modifiers.contains(KeyModifiers::CONTROL) => {
            state.query.push(c);
            state.refilter();
        }
        _ => {}
    }
}

// ── Rendering ───────────────────────────────────────────────────────────────

fn render(frame: &mut Frame, state: &AppState) -> u16 {
    let area = frame.area();

    let has_error = state.error_msg.is_some();
    let status_height = if has_error { 1 } else { 0 };

    let outer = Layout::vertical([
        Constraint::Length(3),
        Constraint::Min(6),
        Constraint::Length(status_height),
    ])
    .split(area);

    render_search_bar(frame, outer[0], state);

    let content = Layout::horizontal([Constraint::Percentage(65), Constraint::Percentage(35)])
        .split(outer[1]);

    render_repo_list(frame, content[0], state);
    render_preview(frame, content[1], state);

    if has_error {
        render_status_bar(frame, outer[2], state);
    }

    content[0].height
}

// ── Search bar ──────────────────────────────────────────────────────────────

fn render_search_bar(frame: &mut Frame, area: Rect, state: &AppState) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(C_BORDER_FOCUS))
        .padding(Padding::horizontal(1));

    let match_count = state.filtered.len();
    let total = state.repos.len();

    let prompt = Span::styled(
        "> ",
        Style::default().fg(C_ACCENT).add_modifier(Modifier::BOLD),
    );
    let query_text = Span::styled(&state.query, Style::default().fg(C_TEXT));
    let cursor = Span::styled(
        " ",
        Style::default()
            .bg(C_TEXT)
            .add_modifier(Modifier::SLOW_BLINK),
    );
    let counter = Span::styled(
        format!("  {match_count}/{total}"),
        Style::default().fg(C_TEXT_MUTED),
    );

    let line = if state.query.is_empty() {
        Line::from(vec![
            prompt,
            Span::styled("Search repositories...", Style::default().fg(C_TEXT_MUTED)),
            cursor,
            Span::raw("  "),
            counter,
        ])
    } else {
        Line::from(vec![prompt, query_text, cursor, Span::raw("  "), counter])
    };

    let paragraph = Paragraph::new(line).block(block);
    frame.render_widget(paragraph, area);
}

// ── Repo list ───────────────────────────────────────────────────────────────

fn render_repo_list(frame: &mut Frame, area: Rect, state: &AppState) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(C_BORDER))
        .padding(Padding::horizontal(1));

    if state.filtered.is_empty() {
        let msg = if state.repos.is_empty() {
            "No repositories found. Use `repodex get` to clone one."
        } else {
            "No matches"
        };
        let empty = Paragraph::new(Line::from(Span::styled(
            msg,
            Style::default()
                .fg(C_TEXT_MUTED)
                .add_modifier(Modifier::ITALIC),
        )))
        .alignment(Alignment::Center)
        .block(block);
        frame.render_widget(empty, area);
        return;
    }

    let selected_idx = state.list_state.selected();

    let items: Vec<ListItem> = state
        .filtered
        .iter()
        .enumerate()
        .map(|(list_i, m)| {
            let repo = &state.repos[m.index];
            let is_selected = selected_idx == Some(list_i);
            let spans = build_highlighted_spans(&repo.relative, &m.match_positions, is_selected);
            ListItem::new(Line::from(spans))
        })
        .collect();

    let list = List::new(items)
        .block(block)
        .highlight_style(
            Style::default()
                .bg(C_HIGHLIGHT_BG)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("  ")
        .highlight_spacing(ratatui::widgets::HighlightSpacing::Always);

    let mut list_state = state.list_state.clone();
    frame.render_stateful_widget(list, area, &mut list_state);

    if state.filtered.len() > area.height.saturating_sub(2) as usize {
        let scrollbar_area = area.inner(Margin {
            vertical: 1,
            horizontal: 0,
        });
        let mut scrollbar_state =
            ScrollbarState::new(state.filtered.len()).position(selected_idx.unwrap_or(0));
        frame.render_stateful_widget(
            Scrollbar::new(ScrollbarOrientation::VerticalRight)
                .style(Style::default().fg(C_BORDER)),
            scrollbar_area,
            &mut scrollbar_state,
        );
    }
}

fn build_highlighted_spans<'a>(
    text: &'a str,
    positions: &[u32],
    is_selected: bool,
) -> Vec<Span<'a>> {
    if positions.is_empty() {
        let style = if is_selected {
            Style::default().fg(C_TEXT)
        } else {
            Style::default().fg(C_TEXT_DIM)
        };
        return vec![Span::styled(text, style)];
    }

    let base = if is_selected {
        Style::default().fg(C_TEXT)
    } else {
        Style::default().fg(C_TEXT_DIM)
    };
    let highlight = Style::default().fg(C_ACCENT).add_modifier(Modifier::BOLD);

    let mut spans = Vec::new();
    let chars: Vec<char> = text.chars().collect();
    let mut match_set = vec![false; chars.len()];
    for &pos in positions {
        if (pos as usize) < chars.len() {
            match_set[pos as usize] = true;
        }
    }

    let mut i = 0;
    while i < chars.len() {
        let is_match = match_set[i];
        let start = i;
        while i < chars.len() && match_set[i] == is_match {
            i += 1;
        }
        let segment: String = chars[start..i].iter().collect();
        if is_match {
            spans.push(Span::styled(segment, highlight));
        } else {
            spans.push(Span::styled(segment, base));
        }
    }

    spans
}

// ── Preview pane ────────────────────────────────────────────────────────────

fn render_preview(frame: &mut Frame, area: Rect, state: &AppState) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(C_BORDER))
        .padding(Padding::horizontal(1));

    let info = match &state.preview {
        Some(info) => info,
        None => {
            let msg = if state.preview_handle.is_some() {
                "Loading..."
            } else {
                "No repository selected"
            };
            let empty = Paragraph::new(Line::from(Span::styled(
                msg,
                Style::default()
                    .fg(C_TEXT_MUTED)
                    .add_modifier(Modifier::ITALIC),
            )))
            .alignment(Alignment::Center)
            .block(block);
            frame.render_widget(empty, area);
            return;
        }
    };

    let inner = block.inner(area);
    frame.render_widget(block, area);

    let mut lines: Vec<Line> = Vec::new();

    // ── Header ──────────────────────────────────────────────────────────
    lines.push(Line::from(Span::styled(
        &info.name,
        Style::default().fg(C_TEXT).add_modifier(Modifier::BOLD),
    )));
    lines.push(Line::from(Span::styled(
        &info.relative,
        Style::default().fg(C_TEXT_DIM),
    )));

    lines.push(Line::from(build_branch_spans(info)));
    lines.push(Line::from(build_change_spans(info)));

    // ── Languages ───────────────────────────────────────────────────────
    if !info.languages.is_empty() {
        lines.push(Line::raw(""));
        lines.push(Line::from(Span::styled(
            "Languages",
            Style::default()
                .fg(C_TEXT)
                .add_modifier(Modifier::BOLD | Modifier::UNDERLINED),
        )));

        let mut lang_spans: Vec<Span> = Vec::new();
        lang_spans.push(Span::raw(" "));
        for (i, (lang, _)) in info.languages.iter().take(8).enumerate() {
            if i > 0 {
                lang_spans.push(Span::styled(", ", Style::default().fg(C_TEXT_MUTED)));
            }
            lang_spans.push(Span::styled(
                lang.as_str(),
                Style::default().fg(lang_color(lang)),
            ));
        }
        if info.languages.len() > 8 {
            lang_spans.push(Span::styled(
                format!(", +{}", info.languages.len() - 8),
                Style::default().fg(C_TEXT_MUTED),
            ));
        }
        lines.push(Line::from(lang_spans));
    }

    // ── File tree ───────────────────────────────────────────────────────
    if !info.tree.is_empty() {
        lines.push(Line::raw(""));
        lines.push(Line::from(Span::styled(
            "Files",
            Style::default()
                .fg(C_TEXT)
                .add_modifier(Modifier::BOLD | Modifier::UNDERLINED),
        )));

        let max_tree = (inner.height as usize).saturating_sub(lines.len() + 4);
        for entry in info.tree.iter().take(max_tree) {
            let is_dir = entry.ends_with('/');
            let style = if is_dir {
                Style::default().fg(C_ACCENT)
            } else {
                Style::default().fg(C_TEXT_DIM)
            };
            lines.push(Line::from(Span::styled(format!(" {entry}"), style)));
        }
        if info.tree.len() > max_tree {
            lines.push(Line::from(Span::styled(
                format!(" ... and {} more", info.tree.len() - max_tree),
                Style::default().fg(C_TEXT_MUTED),
            )));
        }
    }

    // ── Recent commits ──────────────────────────────────────────────────
    let remaining = (inner.height as usize).saturating_sub(lines.len());
    if remaining > 3 && !info.recent_commits.is_empty() {
        lines.push(Line::raw(""));
        lines.push(Line::from(Span::styled(
            "Recent Commits",
            Style::default()
                .fg(C_TEXT)
                .add_modifier(Modifier::BOLD | Modifier::UNDERLINED),
        )));
        for msg in info.recent_commits.iter().take(remaining.saturating_sub(2)) {
            lines.push(Line::from(vec![
                Span::styled("  * ", Style::default().fg(C_YELLOW)),
                Span::styled(msg.as_str(), Style::default().fg(C_TEXT_DIM)),
            ]));
        }
    }

    let paragraph = Paragraph::new(lines);
    frame.render_widget(paragraph, inner);
}

fn build_branch_spans(info: &RepoInfo) -> Vec<Span<'_>> {
    let mut spans = vec![Span::styled(
        &info.branch,
        Style::default().fg(C_CYAN).add_modifier(Modifier::BOLD),
    )];

    if info.ahead > 0 {
        spans.push(Span::styled(
            format!(" +{}", info.ahead),
            Style::default().fg(C_GREEN),
        ));
    }
    if info.behind > 0 {
        spans.push(Span::styled(
            format!(" -{}", info.behind),
            Style::default().fg(C_RED),
        ));
    }

    spans
}

fn build_change_spans(info: &RepoInfo) -> Vec<Span<'static>> {
    let mut spans: Vec<Span<'static>> = Vec::new();

    if info.staged_count > 0 {
        spans.push(Span::styled(
            format!("{} staged", info.staged_count),
            Style::default().fg(C_GREEN),
        ));
    }
    if info.dirty_count > 0 {
        if !spans.is_empty() {
            spans.push(Span::styled("  ", Style::default().fg(C_TEXT_MUTED)));
        }
        spans.push(Span::styled(
            format!("{} modified", info.dirty_count),
            Style::default().fg(C_YELLOW),
        ));
    }
    if info.untracked_count > 0 {
        if !spans.is_empty() {
            spans.push(Span::styled("  ", Style::default().fg(C_TEXT_MUTED)));
        }
        spans.push(Span::styled(
            format!("{} untracked", info.untracked_count),
            Style::default().fg(C_ORANGE),
        ));
    }
    if spans.is_empty() {
        spans.push(Span::styled("clean", Style::default().fg(C_GREEN)));
    }

    spans
}

// ── Status / error bar ──────────────────────────────────────────────────────

fn render_status_bar(frame: &mut Frame, area: Rect, state: &AppState) {
    if let Some(ref msg) = state.error_msg {
        let line = Line::from(Span::styled(
            msg.as_str(),
            Style::default().fg(C_RED).add_modifier(Modifier::BOLD),
        ));
        frame.render_widget(Paragraph::new(line), area);
    }
}

// ── Language colours ────────────────────────────────────────────────────────

fn lang_color(lang: &str) -> Color {
    match lang {
        "Rust" => Color::Yellow,
        "Go" => Color::Cyan,
        "Python" => Color::Blue,
        "JavaScript" => Color::Yellow,
        "TypeScript" => Color::Blue,
        "Ruby" => Color::Red,
        "Java" => Color::Red,
        "C" | "C++" => Color::Blue,
        "C#" => Color::Magenta,
        "Swift" => Color::Red,
        "Kotlin" => Color::Magenta,
        "Zig" => Color::Yellow,
        "Nix" => Color::Cyan,
        "Shell" => Color::Green,
        "HTML" => Color::Red,
        "CSS" => Color::Blue,
        "Haskell" => Color::Magenta,
        "Elixir" => Color::Magenta,
        "Lua" => Color::Blue,
        _ => C_TEXT_DIM,
    }
}
