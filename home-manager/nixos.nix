{ ... }:

{
  imports = [
    ./default.nix
  ];

  home-manager.dev = {
    clojure.enable = true;
    go.enable = true;
    node.enable = true;
    python.enable = true;
  };
}
