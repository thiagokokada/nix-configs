{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.dev.codex;
in
{
  options.home-manager.dev.codex.enable = lib.mkEnableOption "Codex config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.codex =
      let
        codexWithSharedConfig =
          with pkgs;
          symlinkJoin {
            name = "codex-${lib.getVersion codex}";
            paths = [ codex ];
            nativeBuildInputs = [ makeWrapper ];
            postBuild = ''
              rm $out/bin/codex
              makeWrapper ${lib.getExe codex} $out/bin/codex \
                --add-flags "-c check_for_update_on_startup=false"
            '';
          };
      in
      {
        enable = true;
        package = codexWithSharedConfig;
        settings = { };
        # https://developers.openai.com/codex/rules
        rules.basic =
          # starlark
          ''
            prefix_rule(pattern=["pwd"], decision="allow")
            prefix_rule(pattern=["ls"], decision="allow")
            prefix_rule(pattern=["find"], decision="allow")
            prefix_rule(pattern=["grep"], decision="allow")
            prefix_rule(pattern=["rg"], decision="allow")
            prefix_rule(pattern=["cat"], decision="allow")
            prefix_rule(pattern=["sed"], decision="allow")
            prefix_rule(pattern=["head"], decision="allow")
            prefix_rule(pattern=["tail"], decision="allow")
            prefix_rule(pattern=["wc"], decision="allow")
            prefix_rule(pattern=["file"], decision="allow")
            prefix_rule(pattern=["stat"], decision="allow")
            prefix_rule(pattern=["which"], decision="allow")
            prefix_rule(pattern=["diff"], decision="allow")
            prefix_rule(pattern=["nix","build"], decision="allow")
            prefix_rule(pattern=["nix","flake"], decision="allow")
            prefix_rule(pattern=["nix","fmt"], decision="allow")
            prefix_rule(pattern=["nix","eval"], decision="allow")
            prefix_rule(pattern=["git","status"], decision="allow")
            prefix_rule(pattern=["git","diff"], decision="allow")
            prefix_rule(pattern=["git","log"], decision="allow")
            prefix_rule(pattern=["git","show"], decision="allow")
            prefix_rule(pattern=["git","branch"], decision="allow")
            prefix_rule(pattern=["git","rev-parse"], decision="allow")
            prefix_rule(pattern=["git","ls-files"], decision="allow")
            prefix_rule(pattern=["git","remote","-v"], decision="allow")
            prefix_rule(pattern=["git","stash","list"], decision="allow")
            prefix_rule(pattern=["gh","pr", "view"], decision="allow")
            prefix_rule(pattern=["gh","issue","edit"], decision="allow")
            prefix_rule(pattern=["gh","repo","view"], decision="allow")
          '';
      };
  };
}
