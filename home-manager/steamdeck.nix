{ config, pkgs, ... }:

{
  imports = [
    ./emacs
    ./minimal.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    xclip
  ];

  programs.zsh.profileExtra =
    let
      inherit (config.home) homeDirectory;
    in
    ''
      # Load nix environment
      if [ -e "${homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "${homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';
}
