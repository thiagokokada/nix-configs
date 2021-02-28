{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [ smartmontools ];

  hardware = {
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

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  security = {
    # This allows PulseAudio to run with realtime privileges (i.e: less cracks)
    rtkit.enable = true;
    wrappers.noisetorch = {
      source = "${pkgs.unstable.noisetorch}/bin/noisetorch";
      capabilities = "CAP_SYS_RESOURCE=+ep";
    };
  };

  services = {
    smartd = {
      enable = true;
      notifications.x11.enable = true;
    };
    gnome3.gnome-keyring.enable = true;
  };
}
