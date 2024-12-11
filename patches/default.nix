{
  self,
  nixpkgs,
  system,
  ...
}:
let
  args = {
    inherit system;
    config.allowUnfree = true;
    overlays = [ self.overlays.default ];
  };
  pkgs = import nixpkgs args;
  patches = pkgs.callPackage ./patches.nix { };
in
if patches != [ ] then
  let
    nixpkgs' = pkgs.applyPatches {
      inherit patches;
      name = "nixpkgs-patched";
      src = nixpkgs;
    };
  in
  {
    patched = true;
    nixpkgs = nixpkgs';
    pkgs = import nixpkgs' args;
  }
else
  {
    patched = false;
    inherit nixpkgs pkgs;
  }
