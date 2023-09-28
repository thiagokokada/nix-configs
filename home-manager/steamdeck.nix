{ config, pkgs, ... }:

{
  imports = [
    ./minimal.nix
  ];

  home-manager.editor.emacs.enable = true;

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
