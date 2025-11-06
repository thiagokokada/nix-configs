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
        # Define additional models in hosts, since depending on the host vRAM
        # we can run bigger or smaller models
        # https://ollama.com/library
        loadModels = [
          "llama3.2:3b"
        ];
      };
    };
  };
}
