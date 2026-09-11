{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.system.limine;
  memtest86plusEfiPath = "efi/memtest86plus/memtest86plus.efi";
in
{
  options.nixos.system.limine = {
    enableMemtest86Plus = lib.mkEnableOption "Memtest86+ for Limine bootloader";
  };

  config.boot.loader.limine = lib.mkMerge [
    {
      panicOnChecksumMismatch = lib.mkDefault true;
      secureBoot = {
        autoEnrollKeys.enable = lib.mkDefault true;
        autoGenerateKeys = lib.mkDefault true;
      };
      style = {
        wallpapers = [ pkgs.nixos-artwork.wallpapers.binary-blue.gnomeFilePath ];
        wallpaperStyle = "centered";
      };
    }

    (lib.mkIf cfg.enableMemtest86Plus {
      additionalFiles = {
        "${memtest86plusEfiPath}" = pkgs.memtest86plus.efi;
      };
      extraEntries = ''
        /Memtest86+
          protocol: efi_chainload
          image_path: boot():/${memtest86plusEfiPath}
      '';
      # Limine signs itself, but not EFI binaries supplied through additionalFiles.
      # Sign memtest86+ after Limine has copied it and enrolled/generated keys.
      extraInstallCommands = lib.mkIf config.boot.loader.limine.secureBoot.enable ''
        ${lib.getExe config.boot.loader.limine.secureBoot.sbctl} sign \
          "${config.boot.loader.efi.efiSysMountPoint}/${memtest86plusEfiPath}"
      '';
    })
  ];
}
