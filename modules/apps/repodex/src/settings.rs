use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Serialize, Deserialize)]
pub struct Settings {
    /// Primary root directory (first entry). All clones go here.
    pub root_dir: String,
    /// Additional root directories to scan when listing.
    #[serde(default)]
    pub extra_roots: Vec<String>,

    pub select_command: Option<String>,
}

impl Settings {
    /// The primary root used for cloning / creating repos.
    pub fn primary_root(&self) -> PathBuf {
        PathBuf::from(&self.root_dir)
    }

    /// All roots (primary first, then extras). Used for listing / searching.
    pub fn all_roots(&self) -> Vec<PathBuf> {
        let mut roots = vec![self.primary_root()];
        for r in &self.extra_roots {
            let p = PathBuf::from(r);
            if !roots.contains(&p) {
                roots.push(p);
            }
        }
        roots
    }
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            root_dir: String::new(),
            extra_roots: Vec::new(),
            select_command: None,
        }
    }
}
