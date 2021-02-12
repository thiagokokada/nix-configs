#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.requests

# How to use it:
# export GITHUB_TOKEN=...
# $ ./update-zsh-plugins.py | tee ../zsh-plugins.nix

import functools
import os
import sys
from textwrap import dedent

import requests

ZSH_PLUGINS = {
    "zit": {"repo": "github:thiagokokada/zit", "file": "zit.zsh",},
    "zim-completion": {"repo": "github:zimfw/completion", "file": "init.zsh",},
    "zim-environment": {"repo": "github:zimfw/environment", "file": "init.zsh",},
    "zim-input": {"repo": "github:zimfw/input", "file": "init.zsh",},
    "zim-git": {"repo": "github:zimfw/git", "file": "init.zsh",},
    "zim-ssh": {"repo": "github:zimfw/ssh", "file": "init.zsh",},
    "zim-utility": {"repo": "github:zimfw/utility", "file": "init.zsh",},
    "pure": {"repo": "github:sindresorhus/pure@main",},
    "autopair": {"repo": "github:hlissner/zsh-autopair",},
    "zsh-completions": {"repo": "github:zsh-users/zsh-completions",},
    "zsh-syntax-highlighting": {"repo": "github:zsh-users/zsh-syntax-highlighting",},
    "zsh-history-substring-search": {
        "repo": "github:zsh-users/zsh-history-substring-search",
    },
}


GH_TEMPLATE = """\
  {{
    name = "{name}";
    src = fetchGit {{
      url = "https://github.com/{repo}";
      ref = "{ref}";
      rev = "{rev}";
    }};
    file = "{filename}";
  }}\
"""


@functools.lru_cache(maxsize=None)
def get_gh_headers():
    if token := os.environ.get("GITHUB_TOKEN"):
        return {"Authorization": f"token {token}"}
    else:
        print(
            "[WARNING] No GITHUB_TOKEN set. May hit GitHub rate limit!", file=sys.stderr
        )
        return None


def get_rev_from_gh_repo(repo, ref="master"):
    r = requests.get(
        f"https://api.github.com/repos/{repo}/commits/{ref}", headers=get_gh_headers(),
    )
    return r.json()["sha"]


def format_gh_repo(plugin_name, repo, filename=None):
    if not filename:
        filename = f"{plugin_name}.plugin.zsh"

    try:
        repo, ref = repo.split("@")
    except ValueError:
        ref = "master"

    return GH_TEMPLATE.format(
        name=plugin_name,
        repo=repo,
        ref=ref,
        filename=filename,
        rev=get_rev_from_gh_repo(repo, ref),
    )


def main():
    print("# Generated with update-zsh-plugins.py")
    print("{ fetchGit }: [")

    for name, value in ZSH_PLUGINS.items():
        # TODO: implement support for non GitHub
        service, repo = value["repo"].split(":")
        assert service == "github"
        print(format_gh_repo(name, repo, value.get("file")), flush=True)

    print("]")


if __name__ == "__main__":
    main()
