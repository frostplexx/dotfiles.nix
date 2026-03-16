use std::path::{Path, PathBuf};
use std::process::Command;

use color_eyre::eyre::{eyre, Context};

use crate::features::repo_url::RepoSpec;
use crate::AppContext;

pub struct MigrateOptions {
    pub yes: bool,
    pub dry_run: bool,
}

impl Default for MigrateOptions {
    fn default() -> Self {
        Self {
            yes: false,
            dry_run: false,
        }
    }
}

/// Determine the remote-based RepoSpec for a local git repository.
fn spec_from_local_repo(path: &Path) -> color_eyre::Result<RepoSpec> {
    which::which("git").map_err(|_| eyre!("git is not installed or not in PATH"))?;

    let output = Command::new("git")
        .current_dir(path)
        .args(["remote", "get-url", "origin"])
        .output()
        .with_context(|| format!("failed to run git in {}", path.display()))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(eyre!(
            "could not determine remote URL for {}:\n  {}",
            path.display(),
            stderr.trim(),
        ));
    }

    let url = String::from_utf8_lossy(&output.stdout).trim().to_string();
    if url.is_empty() {
        return Err(eyre!(
            "remote 'origin' has an empty URL in {}",
            path.display()
        ));
    }

    RepoSpec::parse(&url).map_err(|e| eyre!("{e}"))
}

pub fn migrate(
    ctx: &AppContext,
    local_path: &str,
    opts: &MigrateOptions,
) -> color_eyre::Result<()> {
    let raw = PathBuf::from(local_path);
    let src = raw.canonicalize().map_err(|e| {
        if !raw.exists() {
            eyre!("path does not exist: {local_path}")
        } else {
            eyre!("cannot resolve path '{local_path}': {e}")
        }
    })?;

    if !src.join(".git").exists() && !src.join("HEAD").exists() {
        return Err(eyre!(
            "{} does not appear to be a git repository (no .git directory found)",
            src.display()
        ));
    }

    let spec = spec_from_local_repo(&src)?;
    let root = ctx.settings.primary_root();
    let dest = spec.local_path(&root);

    if dest.exists() {
        return Err(eyre!(
            "destination already exists: {}\n\
             The repository may already be managed by repodex.",
            dest.display()
        ));
    }

    // Check if src is already inside a root (migrating from managed → managed makes no sense)
    for r in ctx.settings.all_roots() {
        if src.starts_with(&r) {
            return Err(eyre!(
                "{} is already inside root {}\n\
                 Use `repodex rm` and `repodex get` instead.",
                src.display(),
                r.display(),
            ));
        }
    }

    eprintln!("     migrate {} -> {}", src.display(), dest.display());

    if opts.dry_run {
        return Ok(());
    }

    if !opts.yes {
        eprint!("Do you want to proceed? [y/N] ");
        let mut answer = String::new();
        std::io::stdin()
            .read_line(&mut answer)
            .context("failed to read from stdin")?;
        let answer = answer.trim();
        if !answer.eq_ignore_ascii_case("y") && !answer.eq_ignore_ascii_case("yes") {
            eprintln!("aborted");
            return Ok(());
        }
    }

    if let Some(parent) = dest.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create directory {}", parent.display()))?;
    }

    std::fs::rename(&src, &dest)
        .with_context(|| format!("failed to move {} -> {}", src.display(), dest.display()))?;

    println!("{}", dest.display());
    Ok(())
}
