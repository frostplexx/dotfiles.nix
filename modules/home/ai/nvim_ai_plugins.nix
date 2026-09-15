_: {
  flake.homeManagerModules.neovim-plugin-claudecode = {pkgs, ...}: {
    programs = {
      nvf.settings.vim = {
        extraPackages = [
          pkgs.nodejs # needed for pi coding agent
        ];
        assistant = {
          copilot = {
            enable =
              if pkgs.stdenv.hostPlatform.isDarwin
              then true
              else false;

            mappings.suggestion.accept = "<C-cr>";
            setupOpts = {
              suggestion = {
                enabled = true;
                auto_trigger = true;
              };
              nes.enabled = false;
            };
          };
        };
      };
    };
  };
}
