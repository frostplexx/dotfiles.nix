# This module builds the Home Manager configuration for a user.
# It imports the global home configuration and any user-specified modules.
{
  user,
  modules ? [],
}: {
  imports =
    [
      ../../home
    ]
    # Dynamically import each additional home module specified for the user.
    ++ builtins.map (name: ../../home/${name}) modules;
  # Pass the user as a module argument for use in home modules.
  _module.args = {inherit user;};
}
