{
  self,
  system,
  ...
}:
let
  inherit (self.inputs) nixpkgs;
  args = {
    inherit system;
    config = import ../modules/shared/config/nixpkgs.nix;
    overlays = [ self.overlays.default ];
  };
  pkgs = nixpkgs.legacyPackages.${system};
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
    pkgs = import nixpkgs args;
    inherit nixpkgs;
  }
