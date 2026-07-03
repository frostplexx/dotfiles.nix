_: {
    # sidekick.nvim is the AI sidekick that integrates Copilot LSP's "Next Edit
    # Suggestions" with a built-in terminal for any AI CLI. This module configures
    # both the claude-code CLI (themes, skills, statusline) and sidekick.nvim
    # (folke/sidekick.nvim) as the editor integration.
    flake.homeManagerModules.neovim-plugin-claudecode = {pkgs, ...}: {
        programs = {
            opencode = {
                enable = true;
                # pkgs.opencode fails to build on darwin (OOM in nix sandbox smoke test).
                # This stub satisfies HM's lib.versionAtLeast version check (which crashes
                # on null) without building opencode from nixpkgs. The real binary comes
                # from homebrew / external install.
                package = pkgs.runCommandLocal "opencode-stub" {version = "99.0.0";} "mkdir -p $out/bin";

                skills = ./skills;
                context = ''
                    You are a collaborative coding companion. Your role is to help me understand, decide, and grow — not to generate complete solutions unilaterally.

                    Default behavior:
                    - When I describe a problem, ask clarifying questions before writing code unless the task is unambiguously defined.
                    - For non-trivial changes, briefly surface 2-3 approaches with trade-offs and let me choose direction before you start writing.
                    - Write code only when I explicitly ask ("implement this", "go ahead", "write it") or when the scope is already fully agreed.
                    - For small, well-scoped edits (fix this typo, rename this variable), proceed directly.

                    Explain your thinking:
                    - Share the "why" behind your suggestions, not just the "what".
                    - When you spot a better pattern, name it and ask if I want to apply it — don't apply it silently.
                    - Surface any assumptions you are making before acting on them.

                    Scope discipline:
                    - Match your response scope exactly to the request: a question gets an explanation, not a rewrite.
                    - Do not refactor, add features, or clean surrounding code beyond what was explicitly requested.
                    - If you notice related issues while working, mention them in a sentence; do not fix them uninvited.

                    Tone:
                    - Treat me as the decision-maker; you are the advisor.
                    - Keep responses short and direct unless I ask for depth.
                    - Skip trailing summaries of what you just did — I can read the diff.

                    Use the following thing as guidance for you responsens:
                    Terse like caveman. Technical substance exact. Only fluff die.
                    Drop: articles, filler (just/really/basically), pleasantries, hedging.
                    Fragments OK. Short synonyms. Code unchanged.
                    Pattern: [thing] [action] [reason]. [next step].
                    ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
                    Code/commits/PRs: normal.
                '';

                settings = {
                    disabled_providers = [
                        "openai"
                        "gemini"
                        "anthropic"
                    ];
                    provider = {
                        "ollama" = {
                            npm = "@ai-sdk/openai-compatible";
                            name = "Ollama";
                            options = {
                                baseURL = "http://localhost:11434/v1";
                            };
                            models = {
                                "gemma4:31b-cloud" = {
                                    "name" = "gemma4:31b-cloud";
                                };
                            };
                        };
                    };
                };

                themes = {
                    "catppuccin" = pkgs.fetchurl {
                        url = "https://raw.githubusercontent.com/catppuccin/opencode/refs/heads/main/themes/mocha/catppuccin-mocha-blue.json";
                        hash = "sha256-slJfD27nLdgJ/cFhtQageqguGrjHoCdQNRNtHRTHfV0=";
                    };
                };

                tui = {
                    keybinds = {
                        leader = "alt+b";
                    };
                    diff_display = "minimal";
                    theme = "system";
                };
            };

            nvf.settings.vim = {
                assistant = {
                    copilot = {
                        enable =
                            if pkgs.stdenv.isDarwin
                            then true
                            else false;

                        mappings.suggestion.accept = "<C-cr>";
                        setupOpts = {
                            suggestion = {
                                enabled = true;
                                auto_trigger = true;
                            };
                        };
                    };
                };

                # Normal-mode <Tab> applies/jumps the active Next Edit Suggestion.
                # NES suggestions are cleared on InsertEnter/TextChangedI, so they only
                # ever live in normal mode — this is where Tab needs to accept them
                # (insert-mode <Tab> is owned by blink.cmp's super-tab). expr + the
                # "<Tab>" return means a literal Tab is fed only when there is no edit.
                # sidekick is already loaded by the InsertEnter/BufReadPost events below,
                # so require() here is always live.
                keymaps = [
                    {
                        key = "<Tab>";
                        mode = "n";
                        lua = true;
                        expr = true;
                        silent = true;
                        desc = "Sidekick: jump/apply Next Edit Suggestion";
                        action = ''
                            function()
                              if not require("sidekick").nes_jump_or_apply() then
                                return "<Tab>"
                              end
                            end
                        '';
                    }
                ];

                lazy.plugins."sidekick.nvim" = {
                    package = pkgs.vimPlugins.sidekick-nvim;
                    lazy = true;
                    setupModule = "sidekick";
                    setupOpts = {
                        nes = {
                            enabled = true;
                            debounce = 100;
                            trigger = {
                                events = [
                                    "ModeChanged i:n"
                                    "TextChanged"
                                    "User SidekickNesDone"
                                ];
                            };
                            clear = {
                                events = [];
                                esc = true;
                            };
                        };
                        cli = {
                            tools = {
                                opencode = {
                                    cmd = ["/opt/homebrew/bin/opencode"];
                                    env = {
                                        IS_DEMO = "1";
                                        OPENCODE_HIDE_ACCOUNT_INFO = "1";
                                        DISABLE_AUTOUPDATER = "1";
                                    };
                                };
                            };
                            win = {
                                layout = "right";
                            };
                        };
                    };

                    cmd = ["Sidekick"];

                    # NES auto-suggestions are driven by autocmds registered in
                    # require("sidekick").setup(). Loading only on cmd/keys means those
                    # autocmds never arm during normal editing, so load on InsertEnter
                    # (and when a buffer is read) to set sidekick up before the first
                    # i:n / TextChanged trigger fires.
                    event = [
                        "InsertEnter"
                        "BufReadPost"
                    ];

                    keys = [
                        {
                            key = "<leader>aa";
                            mode = "n";
                            lua = true;
                            action = ''function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end'';
                        }
                        {
                            key = "<leader>ad";
                            mode = "n";
                            lua = true;
                            action = ''function() require("sidekick.cli").close() end'';
                        }
                        {
                            key = "<leader>ab";
                            mode = "n";
                            lua = true;
                            action = ''function() require("sidekick.cli").send({ msg = "{file}" }) end'';
                        }
                        {
                            key = "<leader>at";
                            mode = [
                                "x"
                                "n"
                            ];
                            lua = true;
                            action = ''function() require("sidekick.cli").send({ msg = "{this}" }) end'';
                        }
                        {
                            key = "<leader>av";
                            mode = "x";
                            lua = true;
                            action = ''function() require("sidekick.cli").send({ msg = "{selection}" }) end'';
                        }
                        {
                            key = "<leader>ap";
                            mode = [
                                "n"
                                "x"
                            ];
                            lua = true;
                            action = ''function() require("sidekick.cli").prompt() end'';
                        }
                    ];
                };
            };
        };
    };
}
