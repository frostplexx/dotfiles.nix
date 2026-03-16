use std::process::Command;

use color_eyre::eyre::{eyre, Context};

use crate::features::repo_url::RepoSpec;
use crate::AppContext;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PartialCloneMode {
    Blobless,
    Treeless,
}

pub struct GetOptions {
    pub update: bool,
    pub ssh: bool,
    pub shallow: bool,
    pub look: bool,
    pub silent: bool,
    pub branch: Option<String>,
    pub no_recursive: bool,
    pub bare: bool,
    pub partial: Option<PartialCloneMode>,
}

impl Default for GetOptions {
    fn default() -> Self {
        Self {
            update: false,
            ssh: false,
            shallow: false,
            look: false,
            silent: false,
            branch: None,
            no_recursive: false,
            bare: false,
            partial: None,
        }
    }
}

pub fn get(ctx: &AppContext, repository: &str, opts: &GetOptions) -> color_eyre::Result<()> {
    ensure_git_installed()?;

    let spec = RepoSpec::parse(repository).map_err(|e| eyre!("{e}"))?;
    let root = ctx.settings.primary_root();
    let local_path = spec.local_path(&root);

    // Repo already exists locally
    if local_path.exists() {
        if opts.update {
            if !opts.silent {
                eprintln!("     update {}/{}/{}", spec.host, spec.user, spec.project);
            }
            update_repo(&local_path, opts)
                .with_context(|| format!("failed to update {}", local_path.display()))?;
        } else if !opts.silent {
            eprintln!("     exists {}/{}/{}", spec.host, spec.user, spec.project);
        }

        if opts.look {
            println!("{}", local_path.display());
        }
        return Ok(());
    }

    // Clone
    let clone_url = if opts.ssh {
        spec.ssh_url()
    } else {
        spec.https_url()
    };

    if !opts.silent {
        eprintln!("     clone {} -> {}", clone_url, local_path.display());
    }

    if let Some(parent) = local_path.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create directory {}", parent.display()))?;
    }

    let mut cmd = Command::new("git");
    cmd.arg("clone");

    if opts.shallow {
        cmd.args(["--depth", "1"]);
    }
    if let Some(ref branch) = opts.branch {
        cmd.args(["--branch", branch]);
    }
    if opts.bare {
        cmd.arg("--bare");
    }
    if !opts.no_recursive && !opts.bare {
        cmd.arg("--recursive");
    }
    match opts.partial {
        Some(PartialCloneMode::Blobless) => {
            cmd.arg("--filter=blob:none");
        }
        Some(PartialCloneMode::Treeless) => {
            cmd.arg("--filter=tree:0");
        }
        None => {}
    }
    if opts.silent {
        cmd.arg("--quiet");
    }

    cmd.arg(&clone_url);
    cmd.arg(&local_path);

    let status = cmd.status().context("failed to execute git")?;
    if !status.success() {
        // Clean up the (possibly half-created) directory on failure
        let _ = std::fs::remove_dir_all(&local_path);
        return Err(eyre!("git clone exited with status {status}"));
    }

    if opts.look {
        println!("{}", local_path.display());
    }

    Ok(())
}

fn update_repo(path: &std::path::Path, opts: &GetOptions) -> color_eyre::Result<()> {
    let mut cmd = Command::new("git");
    cmd.current_dir(path);
    cmd.args(["pull", "--ff-only"]);

    if opts.silent {
        cmd.arg("--quiet");
    }

    let status = cmd.status().context("failed to execute git pull")?;
    if !status.success() {
        return Err(eyre!("git pull exited with status {status}"));
    }
    Ok(())
}

fn ensure_git_installed() -> color_eyre::Result<()> {
    which::which("git").map_err(|_| {
        eyre!(
            "git is not installed or not in PATH.\n\
             Install git and try again."
        )
    })?;
    Ok(())
}
