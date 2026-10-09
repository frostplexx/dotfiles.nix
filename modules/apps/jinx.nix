_: let
  # Jinx: nix configuration manager (wraps ./jinx/justfile). Same module for
  # nix-darwin and NixOS; the justfile picks `nh darwin`/`nh os` itself.
  module = {pkgs, ...}: let
    jinx = pkgs.writeShellApplication {
      name = "jinx";
      # Everything the recipes call that isn't a general user tool, so jinx
      # works on hosts without a dev setup (tiramisu).
      runtimeInputs = with pkgs; [
        just
        jq
        nh
        alejandra
        statix
        deadnix
      ];
      text = ''
        exec just --justfile "$HOME/dotfiles.nix/modules/apps/jinx/justfile" "$@"
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
