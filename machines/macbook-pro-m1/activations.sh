#!/usr/bin/env bash

echo "running activate settings..."
# Disable mouse acceleration
defaults write "Apple Global Domain" com.apple.mouse.linear -bool true
defaults write "Apple Global Domain" "com.apple.mouse.scaling" -string "0.875"

# Enable transparent menubar
defaults write "Apple Global Domain" SLSMenuBarUseBlurredAppearance -bool false
# Other for custom color or nothing
defaults write "Apple Global Domain" AppleIconAppearanceTintColor Other
# can be either TintedDark, TintedLight, RegularLight, RegularDark, ClearDark, ClearLight or empty for automatic colors
# defaults write "Apple Global Domain" AppleIconAppearanceTheme ClearLight
defaults write "Apple Global Domain" AppleIconAppearanceTheme RegularDark
# Affects Icons, Folders and widgets. Needs to have AppleIconAppearanceTintColor set to Other
# Color is rgba value divided by 256 so its between 0 and 1
defaults write "Apple Global Domain" AppleIconAppearanceCustomTintColor -string "0.7421875 0.53515625 1.000000 1.000000"
# Set highlight color
defaults write "Apple Global Domain" AppleHighlightColor -string "0.7421875 0.53515625 1.000000 Other"

# No idea what it does
defaults write "com.apple.Appearance-Settings.extension" AppleOtherHighlightColor -string "0.7686274509803921 0.6549019607843137 0.9058823529411765"

# Reload settings
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
# osascript -e 'tell application "System Events" to set picture of every desktop to "${assets}/wallpapers/denis-istomin-midnight-gazing.png"'
killall Finder
killall Dock
