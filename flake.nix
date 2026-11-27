{
  description = "MacBook Pro M4 Configuration";

  # Inputs live in .tack/pins.toml and are pinned by .tack/pins.lock.json.
  # Bump them with `tack update`.
  outputs = {self, ...} @ args: let
    inputs = (import ./.tack) {overrides = args.tackOverrides or {};};
  in
    inputs.flake-parts.lib.mkFlake {
      # flake-parts reads per-system inputs from `self.inputs`. This flake has no
      # inputs of its own, so it needs the tack pins there.
      self = self // {inherit inputs;};
      inherit inputs;
    } (inputs.import-tree ./modules);
}
