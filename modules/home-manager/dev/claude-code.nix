{ config, lib, ... }:

let
  cfg = config.home-manager.dev.claude-code;
in
{
  options.home-manager.dev.claude-code.enable = lib.mkEnableOption "Claude Code config";

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      settings = {
        permissions = {
          allow = [
            "Bash(cat:*)"
            "Bash(cd:*)"
            "Bash(echo:*)"
            "Bash(git add:*)"
            "Bash(git branch:*)"
            "Bash(git commit:*)"
            "Bash(git diff:*)"
            "Bash(git log:*)"
            "Bash(git remote -v:*)"
            "Bash(git rev-parse:*)"
            "Bash(git show:*)"
            "Bash(git stash list:*)"
            "Bash(git status:*)"
            "Bash(ls:*)"
            "Bash(find:*)"
            "Bash(head:*)"
            "Bash(tail:*)"
            "Bash(wc:*)"
            "Bash(pwd:*)"
            "Bash(which:*)"
            "Bash(tree:*)"
            "Bash(mkdir:*)"
            "Bash(sbt:*)"
            "Bash(npm run:*)"
            "Bash(npm test:*)"
            "Bash(npm install:*)"
            "Bash(npm ci:*)"
            "Bash(npx:*)"
            "Bash(node:*)"
            "Bash(go build:*)"
            "Bash(go test:*)"
            "Bash(go vet:*)"
            "Bash(go fmt:*)"
            "Bash(go mod tidy:*)"
            "Bash(make:*)"
            "Bash(terraform fmt:*)"
            "Bash(terraform validate:*)"
            "Bash(terraform plan:*)"
            "Bash(gh pr:*)"
            "Bash(gh issue:*)"
            "Bash(gh repo view:*)"
            "Bash(jq:*)"
            "Bash(grep:*)"
            "Bash(rg:*)"
            "Bash(sort:*)"
            "Bash(uniq:*)"
            "Bash(diff:*)"
            "Bash(nix build:*)"
            "Bash(nix flake check:*)"
            "Bash(nix flake show:*)"
            "Bash(nix flake metadata:*)"
            "Bash(nix fmt:*)"
            "Bash(nix eval:*)"
            "Bash(nix develop:*)"
            "Bash(nix log:*)"
            "Bash(nix path-info:*)"
            "Bash(nix search:*)"
            "Bash(nixfmt:*)"
            "Read"
            "Edit"
            "Write"
            "Glob"
            "Grep"
            "Agent"
          ];
          deny = [
            "Bash(rm -rf:*)"
            "Bash(git push --force:*)"
            "Bash(git reset --hard:*)"
            "Bash(git clean -f:*)"
            "Bash(terraform apply:*)"
            "Bash(terraform destroy:*)"
            "Bash(sbt publish:*)"
          ];
        };
      };
    };
  };
}
