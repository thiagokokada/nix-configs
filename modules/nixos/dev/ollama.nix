{
  config,
  lib,
  ...
}:

{
  options.nixos.dev.ollama.enable = lib.mkEnableOption "Ollama config" // {
    default = config.nixos.dev.enable;
  };

  config = lib.mkIf config.nixos.dev.ollama.enable {
    services = {
      ollama = {
        enable = true;
        acceleration = lib.mkIf (config.nixos.games.gpu == "amd") "rocm";
        # Define additional models in hosts, since depending on the host vRAM
        # we can run bigger or smaller models
        loadModels = [
          "llama3.2:3b"
        ];
      };
      open-webui = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
