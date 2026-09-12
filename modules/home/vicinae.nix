_: {
  flake.homeManagerModules.vicinae = {
    pkgs,
    ...
  }: let
    # `pkgs.mkRayCastExtension`'s own fetcher uses a sparse checkout written
    # straight into $out, which vanishes mid-build on darwin. Fetching into a
    # temp clone and moving `rootDir` into place (what `rootDir` does) works.
    fetchExtension = url: {
      name,
      rev,
      hash,
    }:
      pkgs.fetchgit {
        inherit rev hash url;
        sparseCheckout = ["/extensions/${name}"];
        rootDir = "extensions/${name}";
      };

    mkRaycastExtension = args:
      pkgs.mkRayCastExtension {
        inherit (args) name;
        src = fetchExtension "https://github.com/raycast/extensions.git" args;
      };

    # Native vicinae extensions from the official store repo.
    mkNativeExtension = args:
      pkgs.mkVicinaeExtension {
        pname = "vicinae-extension-${args.name}";
        version = "0";
        npmFlags = ["--legacy-peer-deps"];
        src = fetchExtension "https://github.com/vicinaehq/extensions.git" args;
      };
  in {
    programs.vicinae =
      {
        enable = true;
        enableFirefoxIntegration = true;
        # run ./scripts/vicinae-extension-snippet.sh [--native] <extension-name>
        # to get the rev and hash for an extension name
        extensions = [
          (mkRaycastExtension {
            name = "obsidian";
            rev = "47eb39c26ef333e17730a57ede8ac9b0741485b5";
            hash = "sha256-7HZ2UEVZxRrkVYNux3+RM4xgXZdbRxEFGL7tkE/L8uc=";
          })
          (mkNativeExtension {
            name = "vscode-recents";
            rev = "ee117bc64f341ed71b4a27e311f343b12a75f43d";
            hash = "sha256-TZY7DjrgpKzQ/RLdC8AdJqkE8QBi5Z7RZTFRWKkFI9o=";
          })
          (mkRaycastExtension {
            name = "homeassistant";
            rev = "47eb39c26ef333e17730a57ede8ac9b0741485b5";
            hash = "sha256-5KRv63RisBJxleZ2xxyqhbYmrnEpr0K33tfKUj4HIks=";
          })
          (mkNativeExtension {
            name = "coffee";
            rev = "ee117bc64f341ed71b4a27e311f343b12a75f43d";
            hash = "sha256-qK5It2WpEjAu3wEFFTSA0A8Ca2S5zaqgrTd31XBRRec=";
          })
          (mkRaycastExtension {
            name = "kill-process";
            rev = "47eb39c26ef333e17730a57ede8ac9b0741485b5";
            hash = "sha256-s5SnabHsEaAWIudgkn92QFwwyFocDzQbduI4TPEvICU=";
          })
          (mkRaycastExtension {
            name = "audio-device";
            rev = "47eb39c26ef333e17730a57ede8ac9b0741485b5";
            hash = "sha256-5Ph5L01cmVpILGBQobEQl3vK20DPRFRrjiwTpjsLn28=";
          })
          (mkNativeExtension {
            name = "vscode-recents";
            rev = "ee117bc64f341ed71b4a27e311f343b12a75f43d";
            hash = "sha256-TZY7DjrgpKzQ/RLdC8AdJqkE8QBi5Z7RZTFRWKkFI9o=";
          })
        ];
        settings = {
          close_on_focus_loss = false;
          pop_to_root_on_close = true;
          tray = {
            enabled = false;
          };
          global_shortcuts = {
            toggle = "control+SPACE";
          };
          theme = {
            dark = {
              name = "catppuccin-mocha";
            };
          };
          telemetry = {
            system_info = false;
          };
          launcher_window = {
            rounding = 25;
            opacity = 0.8;
            compact_mode = {
              enabled = true;
            };
            floating_status_bar = true;
            material = "liquid_glass";
          };
          providers = {
            "core" = {
              "entrypoints" = {
                "manage-fallback" = {
                  "enabled" = false;
                };
                "refresh-apps" = {
                  "enabled" = false;
                };
              };
            };
            "theme" = {
              "enabled" = false;
            };
            "wm" = {
              "enabled" = false;
            };
            "developer" = {
              "enabled" = false;
            };
            "font" = {
              "enabled" = false;
            };
            "system" = {
              "enabled" = false;
            };
            "@ShyAssassin/vscode-recents" = {
              preferences = {
                vscodeFlavour = "VSCodium";
                windowPreference = "Default";
              };
              entrypoints = {
                "open-recents" = {
                  alias = "vscode";
                };
              };
            };
            "@benvp/audio-device" = {
              entrypoints = {
                "set-output-device" = {
                  shortcut = "super+control+alt+O";
                };
              };
            };
            "@marcjulian/obsidian" = {
              preferences = {
                configFileName = ".obsidian";
                vaultPath = "/Users/daniel/Documents/Memex";
              };
              entrypoints = {
                appendTaskCommand = {
                  enabled = false;
                };
                dailyNoteAppendCommand = {
                  enabled = false;
                };
                dailyNoteCommand = {
                  enabled = false;
                };
                openVaultCommand = {
                  enabled = false;
                };
                openWorkspaceCommand = {
                  enabled = false;
                };
                randomNoteCommand = {
                  enabled = false;
                };
                runActionCommand = {
                  enabled = false;
                };
                searchMedia = {
                  enabled = false;
                };
              };
            };
            "@tonka3000/homeassistant" = {
              preferences = {
                instance = "https://has.int.kuipr.de";
              };
              entrypoints = {
                assist.enabled = false;
                attributes.enabled = false;
                automations.enabled = false;
                batteries.enabled = false;
                binarysensors.enabled = false;
                buttons.enabled = true;
                calendar.enabled = false;
                cameras.enabled = false;
                climate.enabled = false;
                covers.enabled = false;
                customentities.enabled = false;
                dashboard.enabled = false;
                doors.enabled = false;
                "entity-settings".enabled = false;
                fans.enabled = false;
                helpers.enabled = false;
                index.enabled = false;
                mediaplayers.enabled = true;
                motions.enabled = false;
                persons.enabled = false;
                runService.enabled = false;
                scripts.enabled = false;
                sensors.enabled = false;
                services.enabled = false;
                switches.enabled = false;
                updates.enabled = false;
                vacuums.enabled = false;
                weather.enabled = false;
                windows.enabled = false;
                zones.enabled = false;
              };
            };
          };
        };
      }
      // (
        if pkgs.stdenv.hostPlatform.isDarwin
        then {launchd.enable = true;}
        else {systemd.enable = true;}
      );
  };
}
