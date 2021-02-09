#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.requests

# How to use it:
# export GITHUB_TOKEN=...
# $ ./update-zsh-plugins.py | tee ../zsh-plugins.nix

import os
from textwrap import dedent

import requests

ZSH_PLUGINS = {
    "zit": "github:thiagokokada/zit",
    "zim-completion": "github:zimfw/completion",
    "zim-environment": "github:zimfw/environment",
    "zim-input": "github:zimfw/input",
    "zim-git": "github:zimfw/git",
    "zim-ssh": "github:zimfw/ssh",
    "zim-utility": "github:zimfw/utility",
    "pure": "github:sindresorhus/pure@main",
    "autopair": "github:hlissner/zsh-autopair",
    "zsh-completions": "github:zsh-users/zsh-completions",
    "zsh-syntax-highlighting": "github:zsh-users/zsh-syntax-highlighting",
    "zsh-history-substring-search": "github:zsh-users/zsh-history-substring-search",
}


GH_TEMPLATE = """\
  {{
    name = "{name}";
    src = fetchGit {{
      url = "https://github.com/{repo}";
      ref = "{ref}";
      rev = "{rev}";
    }};
  }}\
"""


def get_rev_from_gh_repo(repo, ref="master"):
    token = os.environ.get("GITHUB_TOKEN", "")
    r = requests.get(
        f"https://api.github.com/repos/{repo}/commits/{ref}",
        headers={"Authorization": f"token {token}"},
    )
    return r.json()["sha"]


def format_gh_repo(plugin_name, repo):
    try:
        repo, ref = repo.split("@")
    except ValueError:
        ref = "master"

    return GH_TEMPLATE.format(
        name=plugin_name,
        repo=repo,
        ref=ref,
        rev=get_rev_from_gh_repo(repo, ref),
    )


def main():
    print("# Generated with update-zsh-plugins.py")
    print("{ fetchGit }: [")

    for name, value in ZSH_PLUGINS.items():
        # TODO: implement support for non GitHub
        service, repo = value.split(":")
        assert service == "github"
        print(format_gh_repo(name, repo))

    print("]")


if __name__ == "__main__":
    main()
