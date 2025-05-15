{
    user,
    pkgs,
    lib,
    ...
}: let
    keyPath =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}/.config/age.txt"
        else "/home/${user}/.config/age.txt";

    fetchAgeKey = pkgs.writeShellScriptBin "fetch-age-key" ''
        if [ ! -f "${keyPath}" ]; then
          echo "Fetching age key from 1Password..."
          sudo op read --out-file "${keyPath}" 'op://Personal/dotfiles-age/Private Key'
          chmod 600 "${keyPath}"
        fi
    '';
in {
    home = {
        username = user;
        stateVersion = "23.11";
        sessionVariables = {
            NH_FLAKE = "$HOME/dotfiles.nix";
            EDITOR = "nvim";
        };
    };

    sops = {
        age.keyFile = keyPath;
        age.generateKey = false;
    };

    home.activation.fetchAgeKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${fetchAgeKey}/bin/fetch-age-key
    '';

    programs = {
        home-manager.enable = true; # Let Home Manager manage itself
        # zsh.enable = true; # Basic zsh configuration
    };
}
