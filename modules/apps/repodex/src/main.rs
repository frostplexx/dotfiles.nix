mod features;
mod settings;
mod tui;

use clap::{Parser, Subcommand, ValueEnum};
use color_eyre::eyre::{eyre, Context};
use color_eyre::Result;

#[derive(Debug, Parser)]
#[command(name = "repodex")]
#[command(version, about = "Repo Manager", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Debug, Clone, ValueEnum)]
enum PartialMode {
    Blobless,
    Treeless,
}

#[derive(Debug, Subcommand)]
enum Commands {
    /// Clone/sync a remote repository under the root directory
    #[command(arg_required_else_help = true)]
    Get {
        /// Repository URL or spec (host/user/project, user/project, or project)
        #[arg(value_name = "REPOSITORY")]
        repository: String,

        /// Update the existing repository if it already exists
        #[arg(short = 'u', long)]
        update: bool,

        /// Use SSH for cloning
        #[arg(short = 'p', long)]
        ssh: bool,

        /// Perform a shallow clone (--depth 1)
        #[arg(long)]
        shallow: bool,

        /// Print the destination directory and exit (for shell integration)
        #[arg(long)]
        look: bool,

        /// Suppress output
        #[arg(long)]
        silent: bool,

        /// Clone a specific branch
        #[arg(short, long)]
        branch: Option<String>,

        /// Disable recursive submodule init
        #[arg(long)]
        no_recursive: bool,

        /// Clone as a bare repository
        #[arg(long)]
        bare: bool,

        /// Partial clone mode
        #[arg(long, value_enum)]
        partial: Option<PartialMode>,
    },

    /// List local repositories
    List {
        /// Print full paths
        #[arg(short = 'p', long)]
        full_path: bool,

        /// Exact match for query
        #[arg(short, long)]
        exact: bool,

        /// Filter query
        #[arg(value_name = "QUERY")]
        query: Option<String>,
    },

    /// Create a new local repository
    #[command(arg_required_else_help = true)]
    Create {
        /// Repository spec (host/user/project, user/project, or project)
        #[arg(value_name = "REPOSITORY")]
        repository: String,
    },

    /// Remove a local repository
    #[command(arg_required_else_help = true)]
    Rm {
        /// Repository URL or spec
        #[arg(value_name = "REPOSITORY")]
        repository: String,

        /// Show what would be removed without deleting
        #[arg(long)]
        dry_run: bool,
    },

    /// Move a local repository into the root directory structure
    #[command(arg_required_else_help = true)]
    Migrate {
        /// Path to the local repository
        #[arg(value_name = "PATH")]
        path: String,

        /// Skip confirmation prompt
        #[arg(short = 'y', long)]
        yes: bool,

        /// Show what would be done without actually moving
        #[arg(long)]
        dry_run: bool,
    },

    /// Print the root directory
    Root {
        /// Print all root directories
        #[arg(long)]
        all: bool,
    },
}

pub struct AppContext {
    pub settings: settings::Settings,
}

fn validate_root_dir(ctx: &AppContext) -> Result<()> {
    let root = ctx.settings.primary_root();
    if ctx.settings.root_dir.is_empty() {
        return Err(eyre!(
            "root_dir is not configured.\n\
             Set it in the config file (typically ~/.config/repodex/default-config.yml):\n\n  \
             root_dir: ~/repos"
        ));
    }
    if !root.exists() {
        std::fs::create_dir_all(&root)
            .with_context(|| format!("failed to create root directory: {}", root.display()))?;
    }
    if !root.is_dir() {
        return Err(eyre!(
            "root_dir '{}' exists but is not a directory",
            root.display()
        ));
    }
    Ok(())
}

fn main() -> Result<()> {
    color_eyre::install()?;

    let args = Cli::parse();
    let settings: settings::Settings =
        confy::load("repodex", None).context("failed to load configuration")?;
    let ctx = AppContext { settings };

    match args.command {
        Some(Commands::Get {
            repository,
            update,
            ssh,
            shallow,
            look,
            silent,
            branch,
            no_recursive,
            bare,
            partial,
        }) => {
            validate_root_dir(&ctx)?;
            let opts = features::get::GetOptions {
                update,
                ssh,
                shallow,
                look,
                silent,
                branch,
                no_recursive,
                bare,
                partial: partial.map(|p| match p {
                    PartialMode::Blobless => features::get::PartialCloneMode::Blobless,
                    PartialMode::Treeless => features::get::PartialCloneMode::Treeless,
                }),
            };
            features::get::get(&ctx, &repository, &opts)
                .with_context(|| format!("failed to get '{repository}'"))?;
        }

        Some(Commands::List {
            full_path,
            exact,
            query,
        }) => {
            validate_root_dir(&ctx)?;
            let opts = features::list::ListOptions {
                full_path,
                exact,
                query,
            };
            features::list::list(&ctx, &opts);
        }

        Some(Commands::Create { repository }) => {
            validate_root_dir(&ctx)?;
            features::create::create(&ctx, &repository)
                .with_context(|| format!("failed to create '{repository}'"))?;
        }

        Some(Commands::Rm {
            repository,
            dry_run,
        }) => {
            validate_root_dir(&ctx)?;
            let opts = features::rm::RmOptions { dry_run };
            features::rm::rm(&ctx, &repository, &opts)
                .with_context(|| format!("failed to remove '{repository}'"))?;
        }

        Some(Commands::Migrate { path, yes, dry_run }) => {
            validate_root_dir(&ctx)?;
            let opts = features::migrate::MigrateOptions { yes, dry_run };
            features::migrate::migrate(&ctx, &path, &opts)
                .with_context(|| format!("failed to migrate '{path}'"))?;
        }

        Some(Commands::Root { all }) => {
            if all {
                for root in ctx.settings.all_roots() {
                    println!("{}", root.display());
                }
            } else {
                if ctx.settings.root_dir.is_empty() {
                    return Err(eyre!(
                        "root_dir is not configured.\n\
                         Set it in the config file (typically ~/.config/repodex/default-config.yml):\n\n  \
                         root_dir: ~/repos"
                    ));
                }
                println!("{}", ctx.settings.primary_root().display());
            }
        }

        None => {
            validate_root_dir(&ctx)?;
            ratatui::run(|terminal| tui::app::app(&ctx, terminal))
                .context("TUI exited with an error")?;
        }
    }

    Ok(())
}
