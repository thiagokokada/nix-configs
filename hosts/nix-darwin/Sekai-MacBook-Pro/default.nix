{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # GateIQ rewrites /etc/zshenv as a regular file when adding its CA exports.
  # Keep the Nix-generated content separate so subsequent activations succeed.
  # One-time setup: replace the old Nix section in /etc/zshenv with
  #   source /etc/zshenv.nix-darwin
  # while preserving the GateIQ managed block after it.
  environment.etc."zshenv".target = "zshenv.nix-darwin";

  nix-darwin.home = {
    username = "thiago.okada";
    extraModules = {
      home.stateVersion = "25.11";
      home-manager = {
        editor.idea = {
          enable = true;
          packages = null;
        };
      };
      programs = {
        go.env.GOPRIVATE = "github.com/flowcommerce/*";
        mise.globalConfig.settings.trusted_config_paths = [ "~/Global-e" ];
      };
    };
  };

  homebrew.casks = [ "intellij-idea" ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    nonUS.remapTilde = true;
  };

  # This value determines the nix-darwin release with which your system is to
  # be compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after nix-darwin release notes say you
  # should.
  system.stateVersion = 6; # Did you read the comment?
}
