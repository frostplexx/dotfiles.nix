{pkgs, ...}: {
    # Configure xkeysnail for advanced key remapping
    services.xkeysnail = {
        enable = true;
        config = ''
            # -*- coding: utf-8 -*-
            import re
            from xkeysnail.transform import *

            # Use CapsLock as Hyper key
            define_modmap({
                Key.CAPSLOCK: [Key.LEFT_CTRL, Key.LEFT_SHIFT, Key.LEFT_ALT, Key.LEFT_META]
            })

            # Use CapsLock as Escape when pressed alone
            define_keymap(None, {
                K("CAPSLOCK"): K("Escape"),
            }, "CapsLock as Escape when pressed alone")
        '';
        # Ensure xkeysnail can access input devices
        extraOptions = [
            "--watch"
            "--quiet"
        ];
    };

    # Make sure xkeysnail has permissions to read input devices
    security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.policykit.exec" &&
              action.lookup("program") == "${pkgs.xkeysnail}/bin/xkeysnail" &&
              subject.isInGroup("input")) {
                return polkit.Result.YES;
          }
        });
    '';

    # Create an input group if it doesn't exist and add your user to it
    users.groups.input = {};
    users.users.yourusername = {
        extraGroups = ["input"];
    };

    # Make sure xkeysnail is installed
    environment.systemPackages = with pkgs; [
        xkeysnail
    ];
}
