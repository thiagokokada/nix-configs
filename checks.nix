{ pkgs }:

{
  nixfmt-check =
    pkgs.runCommand "nixfmt-check"
      {
        src = ./.;
        nativeBuildInputs = with pkgs; [ nixfmt-rfc-style ];
      }
      ''
        touch $out
        cd $src
        nixfmt --check .
      '';

  statix-check =
    pkgs.runCommand "statix-check"
      {
        src = ./.;
        nativeBuildInputs = with pkgs; [ statix ];
      }
      ''
        touch $out
        cd $src
        statix check
      '';
}
