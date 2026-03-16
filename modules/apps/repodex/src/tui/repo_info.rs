use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicBool, Ordering};

/// Hard cap on the number of files visited during language detection.
const MAX_LANG_FILES: usize = 500;

/// Hard cap on the number of status entries we'll read from git.
const MAX_STATUS_ENTRIES: usize = 1_000;

/// Information about a single repository, collected lazily for the preview pane.
/// Every field is populated on a best-effort basis — failures are silently
/// swallowed so the TUI never crashes due to one broken repo.
#[allow(dead_code)]
pub struct RepoInfo {
    pub path: PathBuf,
    pub name: String,
    pub relative: String,
    pub branch: String,
    pub dirty_count: usize,
    pub staged_count: usize,
    pub untracked_count: usize,
    pub ahead: usize,
    pub behind: usize,
    pub languages: Vec<(String, usize)>,
    pub recent_commits: Vec<String>,
    pub tree: Vec<String>,
}

impl RepoInfo {
    /// Collect all repo info for a given path.
    /// `cancel` is checked periodically — if it becomes `true` the collection
    /// aborts early and returns whatever was gathered so far.
    pub fn collect(full_path: &Path, root: &Path, cancel: &AtomicBool) -> Self {
        let relative = full_path
            .strip_prefix(root)
            .unwrap_or(full_path)
            .to_string_lossy()
            .to_string();

        let name = full_path
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| relative.clone());

        let mut info = RepoInfo {
            path: full_path.to_path_buf(),
            name,
            relative,
            branch: String::new(),
            dirty_count: 0,
            staged_count: 0,
            untracked_count: 0,
            ahead: 0,
            behind: 0,
            languages: Vec::new(),
            recent_commits: Vec::new(),
            tree: Vec::new(),
        };

        // Each collector is independent — one failing must not block the rest.
        // Check cancellation between each phase.
        info.collect_git(full_path, cancel);
        if cancel.load(Ordering::Relaxed) {
            return info;
        }

        info.collect_languages(full_path, cancel);
        if cancel.load(Ordering::Relaxed) {
            return info;
        }

        info.collect_tree(full_path, 30, cancel);

        info
    }

    // ── Git info ────────────────────────────────────────────────────────

    fn collect_git(&mut self, path: &Path, cancel: &AtomicBool) {
        let repo = match git2::Repository::open(path) {
            Ok(r) => r,
            Err(_) => return,
        };

        self.collect_branch(&repo);
        if cancel.load(Ordering::Relaxed) {
            return;
        }

        self.collect_status(&repo);
        if cancel.load(Ordering::Relaxed) {
            return;
        }

        self.collect_ahead_behind(&repo);
        if cancel.load(Ordering::Relaxed) {
            return;
        }

        self.collect_commits(&repo);
    }

    fn collect_branch(&mut self, repo: &git2::Repository) {
        if let Ok(head) = repo.head() {
            if let Some(name) = head.shorthand() {
                self.branch = name.to_string();
            }
        }
        if self.branch.is_empty() {
            if let Ok(head) = repo.head() {
                if let Some(oid) = head.target() {
                    let s = oid.to_string();
                    self.branch = format!("({})", &s[..s.len().min(8)]);
                }
            }
        }
    }

    fn collect_status(&mut self, repo: &git2::Repository) {
        let mut opts = git2::StatusOptions::new();
        opts.include_untracked(true)
            .recurse_untracked_dirs(false)
            .exclude_submodules(true);

        let statuses = match repo.statuses(Some(&mut opts)) {
            Ok(s) => s,
            Err(_) => return,
        };

        for entry in statuses.iter().take(MAX_STATUS_ENTRIES) {
            let s = entry.status();
            if s.intersects(
                git2::Status::INDEX_NEW
                    | git2::Status::INDEX_MODIFIED
                    | git2::Status::INDEX_DELETED
                    | git2::Status::INDEX_RENAMED
                    | git2::Status::INDEX_TYPECHANGE,
            ) {
                self.staged_count += 1;
            }
            if s.intersects(
                git2::Status::WT_MODIFIED
                    | git2::Status::WT_DELETED
                    | git2::Status::WT_RENAMED
                    | git2::Status::WT_TYPECHANGE,
            ) {
                self.dirty_count += 1;
            }
            if s.contains(git2::Status::WT_NEW) {
                self.untracked_count += 1;
            }
        }
    }

    fn collect_ahead_behind(&mut self, repo: &git2::Repository) {
        let head = match repo.head() {
            Ok(h) => h,
            Err(_) => return,
        };
        let local_oid = match head.target() {
            Some(o) => o,
            None => return,
        };
        let branch_name = head.shorthand().unwrap_or("HEAD");
        let upstream_name = format!("refs/remotes/origin/{branch_name}");
        let upstream_ref = match repo.find_reference(&upstream_name) {
            Ok(r) => r,
            Err(_) => return,
        };
        let upstream_oid = match upstream_ref.target() {
            Some(o) => o,
            None => return,
        };
        if let Ok((ahead, behind)) = repo.graph_ahead_behind(local_oid, upstream_oid) {
            self.ahead = ahead;
            self.behind = behind;
        }
    }

    fn collect_commits(&mut self, repo: &git2::Repository) {
        let mut revwalk = match repo.revwalk() {
            Ok(r) => r,
            Err(_) => return,
        };
        if revwalk.push_head().is_err() {
            return;
        }
        let _ = revwalk.set_sorting(git2::Sort::TIME);

        for oid in revwalk.flatten().take(5) {
            if let Ok(commit) = repo.find_commit(oid) {
                let summary = commit.summary().unwrap_or("").to_string();
                self.recent_commits.push(truncate_str(&summary, 72));
            }
        }
    }

    // ── Language breakdown ──────────────────────────────────────────────

    fn collect_languages(&mut self, path: &Path, cancel: &AtomicBool) {
        let mut counts: HashMap<String, usize> = HashMap::new();
        let mut visited = 0usize;
        Self::walk_for_languages(path, &mut counts, 0, 4, &mut visited, cancel);

        let mut sorted: Vec<(String, usize)> = counts.into_iter().collect();
        sorted.sort_by(|a, b| b.1.cmp(&a.1));
        self.languages = sorted;
    }

    fn walk_for_languages(
        dir: &Path,
        counts: &mut HashMap<String, usize>,
        depth: usize,
        max_depth: usize,
        visited: &mut usize,
        cancel: &AtomicBool,
    ) {
        if depth > max_depth || *visited >= MAX_LANG_FILES || cancel.load(Ordering::Relaxed) {
            return;
        }
        let entries = match fs::read_dir(dir) {
            Ok(e) => e,
            Err(_) => return,
        };

        for entry in entries.flatten() {
            if *visited >= MAX_LANG_FILES || cancel.load(Ordering::Relaxed) {
                return;
            }

            let Ok(ft) = entry.file_type() else {
                continue;
            };
            let name = entry.file_name();
            let name_str = name.to_string_lossy();

            if name_str.starts_with('.') || IGNORED_DIRS.contains(&name_str.as_ref()) {
                continue;
            }

            if ft.is_dir() {
                Self::walk_for_languages(
                    &entry.path(),
                    counts,
                    depth + 1,
                    max_depth,
                    visited,
                    cancel,
                );
            } else if ft.is_file() {
                *visited += 1;
                if let Some(ext) = entry.path().extension() {
                    let lang = ext_to_language(&ext.to_string_lossy());
                    if !lang.is_empty() {
                        *counts.entry(lang.to_string()).or_insert(0) += 1;
                    }
                }
            }
        }
    }

    // ── File tree ───────────────────────────────────────────────────────

    fn collect_tree(&mut self, path: &Path, max_lines: usize, cancel: &AtomicBool) {
        self.tree.clear();
        Self::build_tree(path, "", true, &mut self.tree, max_lines, 0, 3, cancel);
    }

    fn build_tree(
        dir: &Path,
        prefix: &str,
        is_root: bool,
        lines: &mut Vec<String>,
        max_lines: usize,
        depth: usize,
        max_depth: usize,
        cancel: &AtomicBool,
    ) {
        if lines.len() >= max_lines || depth > max_depth || cancel.load(Ordering::Relaxed) {
            return;
        }

        let mut entries: Vec<_> = match fs::read_dir(dir) {
            Ok(e) => e.flatten().collect(),
            Err(_) => return,
        };

        entries.sort_by(|a, b| {
            let a_dir = a.path().is_dir();
            let b_dir = b.path().is_dir();
            match (a_dir, b_dir) {
                (true, false) => std::cmp::Ordering::Less,
                (false, true) => std::cmp::Ordering::Greater,
                _ => a.file_name().cmp(&b.file_name()),
            }
        });

        entries.retain(|e| {
            let name = e.file_name();
            let s = name.to_string_lossy();
            !s.starts_with('.') && !IGNORED_DIRS.contains(&s.as_ref())
        });

        let total = entries.len();
        for (i, entry) in entries.iter().enumerate() {
            if lines.len() >= max_lines || cancel.load(Ordering::Relaxed) {
                if lines.len() < max_lines {
                    lines.push(format!("{prefix}  ..."));
                }
                return;
            }

            let is_last = i == total - 1;
            let connector = if is_root {
                ""
            } else if is_last {
                "└── "
            } else {
                "├── "
            };

            let name = entry.file_name();
            let name_str = name.to_string_lossy();
            let is_dir = entry.path().is_dir();

            let display_name = if is_dir {
                format!("{name_str}/")
            } else {
                name_str.to_string()
            };

            lines.push(format!("{prefix}{connector}{display_name}"));

            if is_dir && depth < max_depth {
                let child_prefix = if is_root {
                    String::new()
                } else if is_last {
                    format!("{prefix}    ")
                } else {
                    format!("{prefix}│   ")
                };
                Self::build_tree(
                    &entry.path(),
                    &child_prefix,
                    false,
                    lines,
                    max_lines,
                    depth + 1,
                    max_depth,
                    cancel,
                );
            }
        }
    }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

const IGNORED_DIRS: &[&str] = &[
    "node_modules",
    "target",
    "vendor",
    "build",
    "dist",
    "__pycache__",
    ".git",
    ".hg",
    ".svn",
    "Pods",
    ".build",
    "zig-out",
    "zig-cache",
    "result",
];

fn truncate_str(s: &str, max_chars: usize) -> String {
    let chars: Vec<char> = s.chars().collect();
    if chars.len() <= max_chars {
        s.to_string()
    } else {
        let end = max_chars.saturating_sub(3);
        let truncated: String = chars[..end].iter().collect();
        format!("{truncated}...")
    }
}

fn ext_to_language(ext: &str) -> &'static str {
    match ext.to_lowercase().as_str() {
        "rs" => "Rust",
        "go" => "Go",
        "py" => "Python",
        "js" => "JavaScript",
        "ts" => "TypeScript",
        "tsx" => "TypeScript",
        "jsx" => "JavaScript",
        "rb" => "Ruby",
        "java" => "Java",
        "kt" => "Kotlin",
        "c" => "C",
        "h" => "C",
        "cpp" | "cc" | "cxx" => "C++",
        "hpp" | "hxx" => "C++",
        "cs" => "C#",
        "swift" => "Swift",
        "m" | "mm" => "Objective-C",
        "zig" => "Zig",
        "hs" => "Haskell",
        "ml" | "mli" => "OCaml",
        "ex" | "exs" => "Elixir",
        "erl" => "Erlang",
        "clj" | "cljs" => "Clojure",
        "scala" => "Scala",
        "lua" => "Lua",
        "sh" | "bash" | "zsh" | "fish" => "Shell",
        "nix" => "Nix",
        "html" | "htm" => "HTML",
        "css" | "scss" | "sass" | "less" => "CSS",
        "vue" => "Vue",
        "svelte" => "Svelte",
        "php" => "PHP",
        "r" => "R",
        "dart" => "Dart",
        "toml" => "TOML",
        "yaml" | "yml" => "YAML",
        "json" => "JSON",
        "md" => "Markdown",
        "sql" => "SQL",
        "proto" => "Protobuf",
        "tf" | "hcl" => "HCL",
        "dockerfile" => "Docker",
        _ => "",
    }
}
