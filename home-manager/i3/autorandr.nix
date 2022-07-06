{ config, lib, pkgs, ... }:

{
  # TODO: reorganize this to load config by hostname
  programs.autorandr = {
    enable = true;
    hooks = {
      postswitch = {
        notify-i3 = "${pkgs.i3}/bin/i3-msg restart";
        reset-wallpaper = "systemctl restart --user wallpaper.service";
      };
    };
    profiles = {
      mikudayo-re-nixos_internal-only = {
        fingerprint.eDP-1-1 = "00ffffffffffff0006af90af00000000081e0104a5221378033e8591565991281f505400000001010101010101010101010101010101348a80a0703864406c30350058c110000018dc3780a070383e406c30350058c110000018000000fd003c90a5a522010a202020202020000000fe004231353648414e30382e34200a00b5";
        config.eDP-1-1 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1080";
          rate = "144.15";
        };
      };
      mikudayo-re-nixos_vesta = {
        fingerprint = {
          HDMI-0 = "00ffffffffffff0010ac55d1563230300620010380502178eab495ac5046a025175054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff00313043574e48330a2020202020000000fc0044454c4c205333343233445743000000fd0030641ea03c000a202020202020010e020336f15001020307111216130446141f05104c5a230907078301000067030c001000384067d85dc401788800681a000001013064e64dd2707ed0a046500e203a001d4e3100001a507800a0a038354030203a001d4e3100001a7e4800e0a0381f4040403a001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a002f";
          eDP-1-1 = "00ffffffffffff0006af90af00000000081e0104a5221378033e8591565991281f505400000001010101010101010101010101010101348a80a0703864406c30350058c110000018dc3780a070383e406c30350058c110000018000000fd003c90a5a522010a202020202020000000fe004231353648414e30382e34200a00b5";
        };
        config = {
          HDMI-0 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "3440x1440";
            rate = "99.98";
          };
          eDP-1-1 = {
            enable = true;
            primary = false;
            position = "760x1440";
            mode = "1920x1080";
            rate = "144.15";
          };
        };
      };
    };
  };
}
