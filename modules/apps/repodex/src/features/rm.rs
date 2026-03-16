use color_eyre::eyre::{eyre, Context};
use git2::Repository;

use crate::features::list::discover_repos;
use crate::features::repo_url::RepoSpec;
use crate::AppContext;

pub struct RmOptions {
    pub dry_run: bool,
}

impl Default for RmOptions {
    fn default() -> Self {
        Self { dry_run: false }
    }
}

pub fn rm(ctx: &AppContext, repository: &str, opts: &RmOptions) -> color_eyre::Result<()> {
    let spec = RepoSpec::parse(repository).map_err(|e| eyre!("{e}"))?;

    // Try the exact path under every root first
    let mut target = None;
    for root in ctx.settings.all_roots() {
        let candidate = spec.local_path(&root);
        if candidate.exists() {
            target = Some(candidate);
            break;
        }
    }

    // Fall back to substring match across discovered repos
    if target.is_none() {
        let repos = discover_repos(ctx);
        let needle = format!("{}/{}/{}", spec.host, spec.user, spec.project);
        target = repos
            .into_iter()
            .find(|p| p.to_string_lossy().contains(&needle));
    }

    let target = match target {
        Some(t) => t,
        None => {
            return Err(eyre!("repository not found: {repository}"));
        }
    };

    // Warn about uncommitted changes
    match Repository::open(&target) {
        Ok(repo) => match repo.statuses(None) {
            Ok(statuses) => {
                let dirty = statuses
                    .iter()
                    .filter(|s| s.status() != git2::Status::CURRENT)
                    .count();
                if dirty > 0 {
                    eprintln!(
                        "warning: {} has {} uncommitted change{}",
                        target.display(),
                        dirty,
                        if dirty == 1 { "" } else { "s" },
                    );
                }
            }
            Err(e) => {
                eprintln!(
                    "warning: could not read status of {}: {e}",
                    target.display()
                );
            }
        },
        Err(_) => {
            // Not a valid git repo — fine, proceed with removal
        }
    }

    if opts.dry_run {
        println!("rm -rf {}", target.display());
        return Ok(());
    }

    std::fs::remove_dir_all(&target)
        .with_context(|| format!("failed to remove {}", target.display()))?;
    eprintln!("     remove {}", target.display());

    // Clean empty parent directories up to a root
    let roots = ctx.settings.all_roots();
    let mut parent = target.parent();
    while let Some(p) = parent {
        if roots.iter().any(|r| r == p) {
            break;
        }
        let is_empty = p
            .read_dir()
            .map(|mut d| d.next().is_none())
            .unwrap_or(false);
        if is_empty {
            let _ = std::fs::remove_dir(p);
            parent = p.parent();
        } else {
            break;
        }
    }

    Ok(())
}
