{ pkgs }:

{
  nixpkgs-fmt-check = pkgs.runCommand "nixpkgs-fmt-check"
    {
      src = ./.;
      nativeBuildInputs = with pkgs; [ nixpkgs-fmt ];
    } ''
    touch $out
    cd $src
    nixpkgs-fmt --check .
  '';

  statix-check = pkgs.runCommand "statix-check"
    {
      src = ./.;
      nativeBuildInputs = with pkgs; [ statix ];
    } ''
    touch $out
    cd $src
    statix check
  '';
}
