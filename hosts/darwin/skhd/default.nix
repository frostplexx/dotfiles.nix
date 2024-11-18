{pkgs, ...}: {
  services.skhd = {
    enable =
      if pkgs.stdenv.isDarwin
      then true
      else false;
    skhdConfig = ''

      # Spotify controls
      cmd + shift - p : osascript -e 'tell application "Spotify" to playpause'
      cmd + shift - left : osascript -e 'tell application "Spotify" to previous track'
      cmd + shift - right : osascript -e 'tell application "Spotify" to next track'
      # F13 and F14 for volume up and down
      f13 : osascript -e 'set volume output volume (output volume of (get volume settings) + 10)'
      f14 : osascript -e 'set volume output volume (output volume of (get volume settings) - 10)'


      ####### Window Management Hotkeys #############
      # change focus
      # (alt) change focus (using hjkl)
      alt - h  : yabai -m window --focus west
      alt - j  : yabai -m window --focus south
      alt - k    : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Move focus with mainMod + hjkl
      cmd + ctrl - h : yabai -m window --swap west || $(yabai -m window --display west; yabai -m display --focus west)
      cmd + ctrl - j : yabai -m window --swap south || $(yabai -m window --display south; yabai -m display --focus south)
      cmd + ctrl - k : yabai -m window --swap north || $(yabai -m window --display north; yabai -m display --focus north)
      cmd + ctrl - l : yabai -m window --swap east || $(yabai -m window --display east; yabai -m display --focus east)

      # Minimize window
      cmd - m : yabai -m window --minimize

      # Restore minimized window (new approach)
      cmd + shift - m : \
          window_id=$(yabai -m query --windows --space | \
                      jq -r 'map(select(has("is-minimized") and .["is-minimized"] == true)) | .[0].id') && \
          if [[ -n "$\{window_id}" && "$\{window_id}" != "null" ]]; then \
              yabai -m window --deminimize "$\{window_id}" --focus; \
          else \
              echo "No minimized windows found on current space"; \
          fi


      # move focused window to previous workspace
      alt + shift - b : yabai -m window --space recent; \
                        yabai -m space --focus recent

      # navigate workspaces next / previous using arrow keys
      # cmd - left  : yabai -m space --focus prev
      # cmd - right : yabai -m space --focus next

      # move focused window to next/prev workspace
      cmd + shift - 1 : yabai -m window --space 1 --focus
      cmd + shift - 2 : yabai -m window --space 2 --focus
      cmd + shift - 3 : yabai -m window --space 3 --focus
      cmd + shift - 4 : yabai -m window --space 4 --focus
      cmd + shift - 5 : yabai -m window --space 5 --focus
      cmd + shift - 6 : yabai -m window --space 6 --focus
      cmd + shift - 7 : yabai -m window --space 7 --focus
      cmd + shift - 8 : yabai -m window --space 8 --focus
      cmd + shift - 9 : yabai -m window --space 9 --focus
      #alt + shift - 0 : yabai -m window --space 10

      # balance size of windows
      alt + shift - 0 : yabai -m space --balance

      # increase window size
      alt + shift - left : yabai -m window --resize left:-20:0
      alt + shift - down : yabai -m window --resize bottom:0:20
      alt + shift - up : yabai -m window --resize top:0:-20
      alt + shift - right : yabai -m window --resize right:20:0


      # change layout of desktop
      alt - b : yabai -m space --layout bsp
      # enable stacking with alt-s
      alt - s : yabai -m space --layout stack
      # enable floating with alt-t
      alt - t : yabai -m space --layout float


      # switch between stacks with alt-tab and alt-shift-tab
      alt - tab : yabai -m window --focus stack.next || yabai -m window --focus stack.first || yabai -m window --focus prev || yabai -m window --focus last
      alt + shift - tab : yabai -m window --focus stack.prev || yabai -m window --focus stack.last || yabai -m window --focus next || yabai -m window --focus first

      # float / unfloat window and center on screen
      cmd + shift - f : yabai -m window --toggle float

      # make floating window fill screen
      alt + cmd - up     : yabai -m window --grid 1:1:0:0:1:1

      # make floating window fill left-half of screen
      alt + cmd - left   : yabai -m window --grid 1:2:0:0:1:1

      # make floating window fill right-half of screen
      alt + cmd - right  : yabai -m window --grid 1:2:1:0:1:1

      # create desktop and follow focus
      # Note: script fails when workspace is empty due to Yabai not reporting the workspace (bug?)
      #       best to use the create + move window command instead of creating a blank window
      alt - n : yabai -m space --create;\
                        index="$(yabai -m query --spaces --display | jq 'map(select(."native-fullscreen" == 0))[-1].index')"; \
                        yabai -m space --focus "$\{index}"

      # toggle sticky
      alt + ctrl - s : yabai -m window --toggle sticky

      # enter fullscreen mode for the focused container
      alt - f : yabai -m window --toggle zoom-fullscreen

      # rotate window tree with alt - r
      alt - r : yabai -m space --rotate 90

      # toggle window native fullscreen
      cmd + ctrl - f : yabai -m window --toggle native-fullscreen

      # focus monitor
      alt + ctrl - x  : yabai -m display --focus recent
      alt + ctrl - z  : yabai -m display --focus prev
      alt + ctrl - c  : yabai -m display --focus next
      alt + ctrl - 1  : yabai -m display --focus 1
      alt + ctrl - 2  : yabai -m display --focus 2
      alt + ctrl - 3  : yabai -m display --focus 3


      # focus spaces
      cmd - 1  : yabai -m space --focus 1
      cmd - 2  : yabai -m space --focus 2
      cmd - 3  : yabai -m space --focus 3
      cmd - 4  : yabai -m space --focus 4
      cmd - 5  : yabai -m space --focus 5
      cmd - 6  : yabai -m space --focus 6
      cmd - 7  : yabai -m space --focus 7
      cmd - 8  : yabai -m space --focus 8
      cmd - 9  : yabai -m space --focus 9
      cmd - 0  : yabai -m space --focus 10


      # open macos screenshort and recording menu with ctrl + shift + 5
      ctrl + cmd - 5 : open -a "Screenshot"

    '';
  };
}
