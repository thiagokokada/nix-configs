{ pkgs, config, inputs, ... }:

{
  imports =
    [ "${inputs.noisetorch-module}/nixos/modules/programs/noisetorch.nix" ];

  environment.systemPackages = with pkgs; [ smartmontools ];

  hardware = {
    # Extra OpenGL options
    opengl = {
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiIntel vaapiVdpau ];
    };

    pulseaudio = {
      enable = true;
      extraConfig = ''
        # Switch between headset and headphone mode (e.g. for calls and music) automatically
        load-module module-bluetooth-policy auto_switch=2
        # Echo cancellation and noise cleanup of mic
        load-module module-echo-cancel aec_method=webrtc
      '';
    };
  };

  programs = {
    noisetorch = {
      enable = true;
      package = pkgs.unstable.noisetorch;
    };
  };

  security = {
    # This allows PulseAudio to run with realtime privileges (i.e: less cracks)
    rtkit.enable = true;
  };

  services = {
    smartd = {
      enable = true;
      notifications.x11.enable = true;
    };
    gnome3.gnome-keyring.enable = true;
  };
}
