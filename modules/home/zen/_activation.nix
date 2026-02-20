{
    lib,
    policyJsonPathZen,
    zenProfilesPath,
    policyJson,
    userJsContent,
    enableCustomTheme,
    catppuccinPalette,
    catppuccinAccent,
    themeFiles,
}: {
    # Install policies.json
    zenBrowserPolicy = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ${policyJsonPathZen}
        echo '${builtins.toJSON policyJson}' > ${policyJsonPathZen}/policies.json
    '';

    # Install user.js to all Zen profiles
    zenBrowserUserJs = lib.hm.dag.entryAfter ["linkGeneration"] ''
        echo "Installing user.js preferences for Zen Browser..."

        if [ -d "${zenProfilesPath}" ]; then
            find "${zenProfilesPath}" -maxdepth 1 -type d \( -name "*default*" -o -name "*Default*" \) 2>/dev/null | while read -r profile; do
                if [ -n "$profile" ] && [ -d "$profile" ]; then
                    user_js="$profile/user.js"

                    cat > "$user_js" << 'EOF'
        ${userJsContent}
        EOF

                    echo "user.js installed for profile: $(basename "$profile")"
                fi
            done
        else
            echo "Zen Browser profiles directory not found. user.js will be installed when profiles are created."
        fi
    '';

    # Install or remove theme files based on enableCustomTheme
    zenBrowserThemeInstall = lib.hm.dag.entryAfter ["linkGeneration"] (
        if enableCustomTheme
        then ''
            echo "Installing Catppuccin ${catppuccinPalette}/${catppuccinAccent} theme for Zen Browser..."

            if [ -d "${zenProfilesPath}" ]; then
                find "${zenProfilesPath}" -maxdepth 1 -type d \( -name "*default*" -o -name "*Default*" \) 2>/dev/null | while read -r profile; do
                    if [ -n "$profile" ] && [ -d "$profile" ]; then
                        chrome_dir="$profile/chrome"
                        mkdir -p "$chrome_dir"

                        cp "${themeFiles}/userChrome.css" "$chrome_dir/" 2>/dev/null || true
                        cp "${themeFiles}/zen-logo.svg" "$chrome_dir/" 2>/dev/null || true

                        if [ -f "${themeFiles}/userContent.css" ]; then
                            cp "${themeFiles}/userContent.css" "$chrome_dir/" 2>/dev/null || true
                        fi

                        echo "Theme installed for profile: $(basename "$profile")"
                    fi
                done
            else
                echo "Zen Browser profiles directory not found. Theme will be installed when profiles are created."
            fi
        ''
        else ''
            echo "Custom themes disabled - removing theme files if they exist..."

            if [ -d "${zenProfilesPath}" ]; then
                find "${zenProfilesPath}" -maxdepth 1 -type d \( -name "*default*" -o -name "*Default*" \) 2>/dev/null | while read -r profile; do
                    if [ -n "$profile" ] && [ -d "$profile" ]; then
                        chrome_dir="$profile/chrome"

                        rm -f "$chrome_dir/userChrome.css" 2>/dev/null || true
                        rm -f "$chrome_dir/userContent.css" 2>/dev/null || true
                        rm -f "$chrome_dir/zen-logo.svg" 2>/dev/null || true

                        rmdir "$chrome_dir" 2>/dev/null || true

                        echo "Theme files removed from profile: $(basename "$profile")"
                    fi
                done
            fi
        ''
    );
}
