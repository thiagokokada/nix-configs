{ pkgs, ... }:

{
  home.packages = with pkgs; [
    expect
    gcc
    nil
    shellcheck
  ];
}
