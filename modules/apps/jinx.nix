_: let
  # Jinx: nix configuration manager (wraps ./jinx/justfile). Same module for
  # nix-darwin and NixOS; the justfile picks `nh darwin`/`nh os` itself.
  module = {pkgs, ...}: let
    jinx = pkgs.writeShellApplication {
      name = "jinx";
      # Everything the recipes call that isn't a general user tool, so jinx
      # works on hosts without a dev setup (tiramisu).
      runtimeInputs = with pkgs; [
        coreutils
        just
        jq
        nh
        alejandra
        statix
        deadnix
      ];
      text = ''
        justfile="$HOME/dotfiles.nix/modules/apps/jinx/justfile"
        status="$HOME/dotfiles.nix/modules/apps/jinx/lib/status.sh"
        report=0

        case "''${1:-}" in
          deploy|d|build|deploy-remote|rollback|search|edit-secret|generate-ssh-hosts|\
          check|doctor|clean|optimise|repair|install-tidaluna|exclude-node-modules|\
          set-hidpi|flush-dns|update|u|update-inputs|update-input|changelog|\
          rollback-inputs|merge-updates)
            report=1
            ;;
        esac

        if [ "$report" -eq 1 ]; then
          "$status" working "Running jinx $*"
        fi

        # shellcheck disable=SC2329 # invoked by trap
        on_signal() {
          if [ "$report" -eq 1 ]; then
            "$status" idle "Cancelled jinx $*"
          fi
          exit 130
        }
        trap on_signal INT TERM HUP

        if just --justfile "$justfile" "$@"; then
          if [ "$report" -eq 1 ]; then
            "$status" "done" "Finished jinx $*"
          fi
          exit 0
        else
          code=$?
          if [ "$report" -eq 1 ]; then
            case "$code" in
              130|143) "$status" idle "Cancelled jinx $*" ;;
              *) "$status" error "jinx $* failed (exit $code)" ;;
            esac
          fi
          exit "$code"
        fi
      '';
    };

    jinxCompletion = pkgs.writeTextFile {
      name = "jinx-completion";
      destination = "/share/fish/vendor_completions.d/jinx.fish";
      text = ''
        # Recipe and alias names with their descriptions, read from just's JSON
        # dump so group headers in `--list` output never leak into completions.
        function __jinx_recipe_descriptions
          set -l justfile "$HOME/dotfiles.nix/modules/apps/jinx/justfile"
          if test -f "$justfile"
            ${pkgs.just}/bin/just --justfile "$justfile" --dump --dump-format json 2>/dev/null | \
              ${pkgs.jq}/bin/jq -r '(.recipes[] | select(.private | not) | "\(.name)\t\(.doc // "")"),
                (.aliases | to_entries[] | "\(.key)\talias for \(.value.target)")'
          end
        end

        # Set up completions for jinx
        complete -c jinx -f -a '(__jinx_recipe_descriptions)' -d 'Recipe'
        complete -c jinx -s h -l help -d 'Print help information'
        complete -c jinx -s f -l justfile -r -d 'Use justfile <JUSTFILE>'
        complete -c jinx -s d -l working-directory -r -d 'Use working directory <WORKING-DIRECTORY>'
        complete -c jinx -s v -l verbose -d 'Use verbose output'
        complete -c jinx -s n -l dry-run -d 'Print what just would do without doing it'
        complete -c jinx -s s -l show -r -d 'Show recipe <RECIPE>'
        complete -c jinx -l dump -d 'Dump evaluated justfile'
        complete -c jinx -l list -d 'List available recipes'
        complete -c jinx -l summary -d 'List names of available recipes'
      '';
    };
  in {
    environment.systemPackages = [
      jinx
      jinxCompletion
    ];
  };
in {
  flake.darwinModules.jinx = module;
  flake.nixOSModules.jinx = module;
}
