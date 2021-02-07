{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
    })
  ];
}
