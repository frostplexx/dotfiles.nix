_: {
  flake.homeManagerModules.vicinae = {
    pkgs,
    lib,
    ...
  }: let
    sources = builtins.fromJSON (builtins.readFile ./vicinae-extensions.json);

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
        src = fetchExtension sources.raycast.url args;
      };

    # Native vicinae extensions from the official store repo.
    mkNativeExtension = args:
      pkgs.mkVicinaeExtension {
        pname = "vicinae-extension-${args.name}";
        version = "0";
        npmFlags = ["--legacy-peer-deps"];
        src = fetchExtension sources.vicinae.url args;
      };

    mkAll = mk: repo:
      lib.pipe sources.${repo}.extensions [
        (lib.filterAttrs (_: pin: !(pin.darwinOnly or false) || pkgs.stdenv.hostPlatform.isDarwin))
        (lib.mapAttrsToList (
          name: pin:
            mk (
              {
                inherit name;
              }
              // removeAttrs pin [
                "pinned"
                "darwinOnly"
              ]
            )
        ))
      ];
  in {
    programs.vicinae =
      {
        enable = true;
        enableFirefoxIntegration = true;
        # ./scripts/vicinae-extensions.sh add <raycast|vicinae> <name>
        extensions = mkAll mkRaycastExtension "raycast" ++ mkAll mkNativeExtension "vicinae";
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
            light = {
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
            "shortcuts" = {
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

            "@mooxl/deepcast" = {
              "entrypoints" = {
                "arabic" = {
                  "enabled" = false;
                };
                "bulgarian" = {
                  "enabled" = false;
                };
                "chinese" = {
                  "enabled" = false;
                };
                "czech" = {
                  "enabled" = false;
                };
                "danish" = {
                  "enabled" = false;
                };
                "dutch" = {
                  "enabled" = false;
                };
                "englishUK" = {
                  "enabled" = false;
                };
                "englishUS" = {
                  "enabled" = false;
                };
                "estonian" = {
                  "enabled" = false;
                };
                "finnish" = {
                  "enabled" = false;
                };
                "french" = {
                  "enabled" = false;
                };
                "german" = {
                  "enabled" = false;
                };
                "greek" = {
                  "enabled" = false;
                };
                "hungarian" = {
                  "enabled" = false;
                };
                "indonesian" = {
                  "enabled" = false;
                };
                "italian" = {
                  "enabled" = false;
                };
                "japanese" = {
                  "enabled" = false;
                };
                "korean" = {
                  "enabled" = false;
                };
                "latvian" = {
                  "enabled" = false;
                };
                "lithuanian" = {
                  "enabled" = false;
                };
                "norwegian" = {
                  "enabled" = false;
                };
                "polish" = {
                  "enabled" = false;
                };
                "portuguese" = {
                  "enabled" = false;
                };
                "portugueseBrazil" = {
                  "enabled" = false;
                };
                "romanian" = {
                  "enabled" = false;
                };
                "russian" = {
                  "enabled" = false;
                };
                "slovak" = {
                  "enabled" = false;
                };
                "slovenian" = {
                  "enabled" = false;
                };
                "spanish" = {
                  "enabled" = false;
                };
                "swedish" = {
                  "enabled" = false;
                };
                "turkish" = {
                  "enabled" = false;
                };
                "ukrainian" = {
                  "enabled" = false;
                };
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
