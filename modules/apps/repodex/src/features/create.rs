use std::process::Command;

use color_eyre::eyre::{eyre, Context};

use crate::features::repo_url::RepoSpec;
use crate::AppContext;

pub fn create(ctx: &AppContext, repository: &str) -> color_eyre::Result<()> {
    which::which("git").map_err(|_| eyre!("git is not installed or not in PATH"))?;

    let spec = RepoSpec::parse(repository).map_err(|e| eyre!("{e}"))?;
    let root = ctx.settings.primary_root();
    let local_path = spec.local_path(&root);

    if local_path.exists() {
        eprintln!("     exists {}/{}/{}", spec.host, spec.user, spec.project);
        println!("{}", local_path.display());
        return Ok(());
    }

    std::fs::create_dir_all(&local_path)
        .with_context(|| format!("failed to create directory {}", local_path.display()))?;

    let status = Command::new("git")
        .arg("init")
        .arg(&local_path)
        .status()
        .context("failed to execute git init")?;

    if !status.success() {
        // Clean up directory we just created
        let _ = std::fs::remove_dir_all(&local_path);
        return Err(eyre!("git init exited with status {status}"));
    }

    println!("{}", local_path.display());
    Ok(())
}
