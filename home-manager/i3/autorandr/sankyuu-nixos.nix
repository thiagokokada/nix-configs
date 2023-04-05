{ config, lib, pkgs, ... }:

{
  programs.autorandr.profiles =
    let
      fingerprint = {
        HDMI-1 = "00ffffffffffff0010ac55d1563230300620010380502178eab495ac5046a025175054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff00313043574e48330a2020202020000000fc0044454c4c205333343233445743000000fd0030641ea03c000a202020202020010e020336f15001020307111216130446141f05104c5a230907078301000067030c001000384067d85dc401788800681a000001013064e64dd2707ed0a046500e203a001d4e3100001a507800a0a038354030203a001d4e3100001a7e4800e0a0381f4040403a001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a002f";
      };
    in
    {
      external-only = {
        inherit fingerprint;
        config = {
          HDMI-1 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "3440x1440";
            rate = "99.98";
          };
        };
      };
    };
}