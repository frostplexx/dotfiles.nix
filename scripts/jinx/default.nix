{pkgs, ...}: let
  jinx = pkgs.writeShellApplication {
    name = "jinx";
    runtimeInputs = [pkgs.just];
    text = ''
      exec just --justfile "$HOME/dotfiles.nix/scripts/jinx/justfile" "$@"
    '';
  };

  jinxCompletion = pkgs.writeTextFile {
    name = "jinx-completion";
    destination = "/share/fish/vendor_completions.d/jinx.fish";
    text = ''
      # Function to get available recipes
      function __jinx_recipes
        set -l justfile "$HOME/dotfiles.nix/scripts/jinx/justfile"
        if test -f "$justfile"
          ${pkgs.just}/bin/just --justfile "$justfile" --summary 2>/dev/null | string split ' '
        end
      end

      # Function to get recipe descriptions
      function __jinx_recipe_descriptions
        set -l justfile "$HOME/dotfiles.nix/scripts/jinx/justfile"
        if test -f "$justfile"
          ${pkgs.just}/bin/just --justfile "$justfile" --list 2>/dev/null | \
            string match -r '^\s*(\S+)\s*(.*)$' | \
            while read -l recipe desc
              echo "$recipe"(test -n "$desc"; and echo -e "\t$desc")
            end
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
  environment.systemPackages = [jinx jinxCompletion];
}
