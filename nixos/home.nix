{ config, lib, flake, ... }:

{
  imports = [
    flake.inputs.home.nixosModules.home-manager
    ../modules/meta.nix
  ];

  options.nixos.home = {
    enable = lib.mkDefaultOption "home config";
    username = lib.mkOption {
      description = "Main username";
      type = lib.types.str;
      default = config.meta.username;
    };
    imports = lib.mkOption {
      description = "Modules to import";
      type = lib.types.listOf lib.types.path;
      default = [ ../home-manager/nixos.nix ];
    };
  };

  config = lib.mkIf config.nixos.home.enable {
    home-manager = {
      useUserPackages = true;
      users.${config.nixos.home.username} = {
        inherit (config.nixos.home) imports;
      };
      extraSpecialArgs = { inherit flake; };
    };
  };
}
