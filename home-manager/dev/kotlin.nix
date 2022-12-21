{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kotlin-language-server
  ];
}
