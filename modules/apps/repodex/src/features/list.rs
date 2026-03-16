use std::fs;
use std::path::{Path, PathBuf};

use crate::AppContext;

/// Discover all git repositories under the given root directory.
/// Returns (root, repo_full_path) pairs so callers can compute relative paths.
fn discover_repos_in_root(root: &Path) -> Vec<(PathBuf, PathBuf)> {
    let mut repos = Vec::new();

    let hosts = match fs::read_dir(root) {
        Ok(h) => h,
        Err(_) => return repos,
    };

    for host in hosts.flatten() {
        let host_path = host.path();
        if !host_path.is_dir() {
            continue;
        }

        let users = match fs::read_dir(&host_path) {
            Ok(u) => u,
            Err(_) => continue,
        };

        for user in users.flatten() {
            let user_path = user.path();
            if !user_path.is_dir() {
                continue;
            }

            let repos_iter = match fs::read_dir(&user_path) {
                Ok(r) => r,
                Err(_) => continue,
            };

            for repo in repos_iter.flatten() {
                let repo_path = repo.path();
                if repo_path.join(".git").exists() || repo_path.join("HEAD").exists() {
                    repos.push((root.to_path_buf(), repo_path));
                }
            }
        }
    }

    repos
}

/// Discover repos across all configured roots.
pub fn discover_all_repos(ctx: &AppContext) -> Vec<(PathBuf, PathBuf)> {
    let mut all = Vec::new();
    for root in ctx.settings.all_roots() {
        all.extend(discover_repos_in_root(&root));
    }
    all
}

/// Convenience: return just the full paths (used by TUI, rm, etc.).
pub fn discover_repos(ctx: &AppContext) -> Vec<PathBuf> {
    discover_all_repos(ctx)
        .into_iter()
        .map(|(_, full)| full)
        .collect()
}

pub struct ListOptions {
    /// Print full (absolute) paths instead of relative.
    pub full_path: bool,
    /// Use exact match instead of substring for the query.
    pub exact: bool,
    /// Optional filter query.
    pub query: Option<String>,
}

impl Default for ListOptions {
    fn default() -> Self {
        Self {
            full_path: false,
            exact: false,
            query: None,
        }
    }
}

pub fn list(ctx: &AppContext, opts: &ListOptions) {
    let repos = discover_all_repos(ctx);

    for (root, full_path) in &repos {
        let relative = full_path
            .strip_prefix(root)
            .unwrap_or(full_path)
            .to_string_lossy();

        let display = if opts.full_path {
            full_path.to_string_lossy().to_string()
        } else {
            relative.to_string()
        };

        // Apply query filter
        if let Some(ref query) = opts.query {
            let haystack = &relative;
            let matches = if opts.exact {
                haystack == query.as_str()
            } else {
                haystack.contains(query.as_str())
            };
            if !matches {
                continue;
            }
        }

        println!("{display}");
    }
}
