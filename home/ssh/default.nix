{
    programs.ssh = {
        enable = true;
        # Global SSH settings
        extraConfig = ''
            AddKeysToAgent yes
            ServerAliveInterval 60
            Include ~/.orbstack/ssh/config
            Include ~/.ssh/1Password/config
            IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            ForwardAgent yes
            Match host * exec "test -z $SSH_TTY"
              IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        '';
    };
}
