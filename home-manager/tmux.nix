{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    historyLimit = 10000;
    keyMode = "vi";
    newSession = true;
    sensibleOnTop = true;
    shortcut = "a";
    terminal = "screen-256color";
    secureSocket = false;
    extraConfig = ''
      # enable auto renaming
      setw -g automatic-rename on

      # enable wm window titles
      set -g set-titles on

      # hostname, window number, program name
      set -g set-titles-string '#H: #S.#I.#P #W'

      # enable mouse pointer actions
      set -g mouse on

      # monitor activity between windows
      setw -g monitor-activity on
      set -g visual-activity on

      # show current mode
      set -g status-left '#{prefix_highlight} '
      set -g status-right ' "#{=21:pane_title}" | %H:%M %d-%b-%y'
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.tmux-colors-solarized;
        extraConfig = ''
          set -g @colors-solarized '256'
        '';
      }
      {
        plugin = tmuxPlugins.prefix-highlight;
        extraConfig = ''
          set -g @prefix_highlight_prefix_prompt 'Prefix'
          set -g @prefix_highlight_show_copy_mode 'on'
          set -g @prefix_highlight_copy_prompt 'Copy'
          set -g @prefix_highlight_empty_has_affixes 'on'
          set -g @prefix_highlight_empty_prompt 'Tmux'
        '';
      }
      tmuxPlugins.copycat
      tmuxPlugins.pain-control
      tmuxPlugins.yank
    ];
  };
}
