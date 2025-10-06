_: {
  services.picom = {
    enable = true;
    inactiveOpacity = 1;
    backend = "glx"; # Use glx for better blur performance
    vSync = true; # Prevents screen tearing
    settings = {
      blur = {
        method = "dual_kawase"; # Better looking blur for Spotlight effect
        strength = 7; # Higher value for more blur
      };

      # Add transparency specifically for Rofi
      opacity-rule = [
        "80:class_g = 'Rofi'"
      ];

      # Rounded corners configuration
      corner-radius = 12;
      round-borders = 1;

      # Exclude certain windows from having rounded corners
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "class_g = 'i3bar'"
        "class_g = 'i3-frame'"
      ];

      # Additional picom settings for better appearance
      shadow = true;
      shadow-radius = 15;
      shadow-offset-x = -12;
      shadow-offset-y = -12;
      shadow-opacity = 0.75;

      # Shadow exclusions
      shadow-exclude = [
        "! name~=''"
        "name = 'Notification'"
        "class_g = 'Conky'"
        "class_g = 'Polybar'"
      ];

      # Fading effects (smoother transitions)
      fading = true;
      fade-in-step = 0.08;
      fade-out-step = 0.08;
      fade-delta = 5;
    };
  };
}
