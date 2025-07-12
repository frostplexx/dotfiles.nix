
{ user, modules ? [] }:
{
  imports =
    [
      ../../home
    ]
    ++ builtins.map (name: ../../home/${name}) modules;
  _module.args = { inherit user; };
}
