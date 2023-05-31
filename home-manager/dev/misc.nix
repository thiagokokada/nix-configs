{ pkgs, ... }:

{
  home.packages = with pkgs; [
    expect
    gcc
    nil
    nodePackages.bash-language-server
    shellcheck
  ];
}
