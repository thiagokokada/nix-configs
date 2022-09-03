{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.kotlin-language-server
  ];
}
