use std::path::PathBuf;

/// Parsed repository information, normalised to host / user / project.
#[derive(Debug, Clone)]
pub struct RepoSpec {
    pub host: String,
    pub user: String,
    pub project: String,
}

const DEFAULT_HOST: &str = "github.com";

impl RepoSpec {
    /// Parse a ghq-style repository argument into a `RepoSpec`.
    ///
    /// Accepted formats:
    ///   - Full HTTPS URL:  `https://github.com/user/repo` or `https://github.com/user/repo.git`
    ///   - Full SSH URL:    `git@github.com:user/repo.git`
    ///   - `host/user/project`
    ///   - `user/project`   (host defaults to github.com)
    ///   - `project`        (host defaults to github.com, user defaults to current OS user)
    pub fn parse(input: &str) -> Result<Self, String> {
        let input = input.trim();
        if input.is_empty() {
            return Err("repository argument is empty".into());
        }

        // SSH URL: git@host:user/repo.git
        if input.starts_with("git@") {
            return Self::parse_ssh(input);
        }

        // HTTPS/HTTP URL
        if input.starts_with("https://") || input.starts_with("http://") {
            return Self::parse_https(input);
        }

        // Bare path forms: host/user/project | user/project | project
        Self::parse_bare(input)
    }

    fn parse_ssh(input: &str) -> Result<Self, String> {
        let rest = input
            .strip_prefix("git@")
            .ok_or_else(|| format!("invalid SSH URL: {input}"))?;
        let (host, path) = rest
            .split_once(':')
            .ok_or_else(|| format!("SSH URL missing ':' separator: {input}"))?;

        if host.is_empty() {
            return Err(format!("SSH URL has empty host: {input}"));
        }

        let parts: Vec<&str> = path.trim_end_matches(".git").split('/').collect();
        if parts.len() < 2 || parts.iter().any(|p| p.is_empty()) {
            return Err(format!("SSH URL path must contain user/repo: {input}"));
        }
        Ok(Self {
            host: host.to_string(),
            user: parts[0].to_string(),
            project: parts[1].to_string(),
        })
    }

    fn parse_https(input: &str) -> Result<Self, String> {
        let without_scheme = input
            .strip_prefix("https://")
            .or_else(|| input.strip_prefix("http://"))
            .unwrap_or(input);

        let parts: Vec<&str> = without_scheme
            .split('/')
            .filter(|s| !s.is_empty())
            .collect();

        if parts.len() < 3 {
            return Err(format!(
                "URL must contain host/user/repo (got {} component{}): {input}",
                parts.len(),
                if parts.len() == 1 { "" } else { "s" },
            ));
        }
        Ok(Self {
            host: parts[0].to_string(),
            user: parts[1].to_string(),
            project: parts[2].trim_end_matches(".git").to_string(),
        })
    }

    fn parse_bare(input: &str) -> Result<Self, String> {
        // Reject anything that looks like it might be a URL scheme we don't handle
        if input.contains("://") {
            return Err(format!("unsupported URL scheme: {input}"));
        }

        let parts: Vec<&str> = input.split('/').filter(|s| !s.is_empty()).collect();
        match parts.len() {
            3 => Ok(Self {
                host: parts[0].to_string(),
                user: parts[1].to_string(),
                project: parts[2].trim_end_matches(".git").to_string(),
            }),
            2 => Ok(Self {
                host: DEFAULT_HOST.to_string(),
                user: parts[0].to_string(),
                project: parts[1].trim_end_matches(".git").to_string(),
            }),
            1 => {
                let project = parts[0].trim_end_matches(".git");
                if project.is_empty() {
                    return Err("project name is empty".into());
                }
                let current_user = users::get_current_username()
                    .map(|u| u.to_string_lossy().to_string())
                    .unwrap_or_else(|| "unknown".to_string());
                Ok(Self {
                    host: DEFAULT_HOST.to_string(),
                    user: current_user,
                    project: project.to_string(),
                })
            }
            0 => Err("repository argument is empty".into()),
            _ => Err(format!(
                "too many path components ({}): {input}",
                parts.len()
            )),
        }
    }

    /// The local directory path under a given root:  `<root>/<host>/<user>/<project>`
    pub fn local_path(&self, root: &std::path::Path) -> PathBuf {
        root.join(&self.host).join(&self.user).join(&self.project)
    }

    /// Build a clone-able HTTPS URL.
    pub fn https_url(&self) -> String {
        format!("https://{}/{}/{}.git", self.host, self.user, self.project)
    }

    /// Build a clone-able SSH URL.
    pub fn ssh_url(&self) -> String {
        format!("git@{}:{}/{}.git", self.host, self.user, self.project)
    }
}
