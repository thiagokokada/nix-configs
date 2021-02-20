# Generated with update-zsh-plugins.py
{ fetchGit }: [
  {
    name = "zit";
    src = fetchGit {
      url = "https://github.com/thiagokokada/zit";
      ref = "master";
      rev = "15a02d6b0dc22b4d4e70cfec9242dee8501404ff";
    };
    file = "zit.zsh";
  }
  {
    name = "zim-completion";
    src = fetchGit {
      url = "https://github.com/zimfw/completion";
      ref = "master";
      rev = "db9c17717864e424e3e0e2f69afa4b83db78b559";
    };
    file = "init.zsh";
  }
  {
    name = "zim-environment";
    src = fetchGit {
      url = "https://github.com/zimfw/environment";
      ref = "master";
      rev = "016d897e909eca6efc6f8bb95b4b952e0b4a5424";
    };
    file = "init.zsh";
  }
  {
    name = "zim-input";
    src = fetchGit {
      url = "https://github.com/zimfw/input";
      ref = "master";
      rev = "2f95e2aeed9b4cc3e383adcb41c7a9e8d9f8d89d";
    };
    file = "init.zsh";
  }
  {
    name = "zim-git";
    src = fetchGit {
      url = "https://github.com/zimfw/git";
      ref = "master";
      rev = "921e2d06d68a0120c6d01a17656810e95aa9bfac";
    };
    file = "init.zsh";
  }
  {
    name = "zim-ssh";
    src = fetchGit {
      url = "https://github.com/zimfw/ssh";
      ref = "master";
      rev = "f4182fa0a790e59ffe02beaa96e5ac3a36c72f26";
    };
    file = "init.zsh";
  }
  {
    name = "zim-utility";
    src = fetchGit {
      url = "https://github.com/zimfw/utility";
      ref = "master";
      rev = "5fc2348ff5688972cdc87a2010796525e9656966";
    };
    file = "init.zsh";
  }
  {
    name = "pure";
    src = fetchGit {
      url = "https://github.com/sindresorhus/pure";
      ref = "main";
      rev = "ff356fa2c7ea745bc4bc56a98632bac55c6c74a1";
    };
    file = "pure.plugin.zsh";
  }
  {
    name = "autopair";
    src = fetchGit {
      url = "https://github.com/hlissner/zsh-autopair";
      ref = "master";
      rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
    };
    file = "autopair.plugin.zsh";
  }
  {
    name = "zsh-completions";
    src = fetchGit {
      url = "https://github.com/zsh-users/zsh-completions";
      ref = "master";
      rev = "c7baec49d3e044121f7a37b65a84461ef8dac2de";
    };
    file = "zsh-completions.plugin.zsh";
  }
  {
    name = "zsh-syntax-highlighting";
    src = fetchGit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting";
      ref = "master";
      rev = "5eb494852ebb99cf5c2c2bffee6b74e6f1bf38d0";
    };
    file = "zsh-syntax-highlighting.plugin.zsh";
  }
  {
    name = "zsh-history-substring-search";
    src = fetchGit {
      url = "https://github.com/zsh-users/zsh-history-substring-search";
      ref = "master";
      rev = "0f80b8eb3368b46e5e573c1d91ae69eb095db3fb";
    };
    file = "zsh-history-substring-search.plugin.zsh";
  }
]
