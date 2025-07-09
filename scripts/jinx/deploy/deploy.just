
[group('nix')]
[doc('Deploy system configuration')]
deploy host="$(hostname)": lint
    @echo "Deploying system configuration without update..."
    @git add .
    @nh {{nix_cmd}} switch -H {{host}}
