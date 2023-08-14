{ config
, lib
, pkgs
, areaScreenShot
, fullScreenShot
, menu
, browser ? "${lib.getExe config.programs.firefox.package}"
, dunstctl ? "${pkgs.dunst}/bin/dunstctl"
, fileManager ? "${terminal} ${lib.getExe config.programs.nnn.finalPackage} -a -P p"
, light ? "light" # needs to be installed system-wide
, pamixer ? "${lib.getExe pkgs.pamixer}"
, playerctl ? "${lib.getExe pkgs.pamixer}"
, terminal ? "${config.programs.kitty.package}/bin/kitty"
, statusCommand ? null
, alt ? "Mod1"
, modifier ? "Mod4"
, bars ? with config.theme.colors; [{
    inherit fonts statusCommand;

    position = "top";
    colors = {
      background = base00;
      separator = base01;
      statusline = base04;
      activeWorkspace = {
        border = base03;
        background = base03;
        text = base00;
      };
      bindingMode = {
        border = base0A;
        background = base0A;
        text = base00;
      };
      focusedWorkspace = {
        border = base0D;
        background = base0D;
        text = base00;
      };
      inactiveWorkspace = {
        border = base01;
        background = base01;
        text = base05;
      };
      urgentWorkspace = {
        border = base08;
        background = base08;
        text = base00;
      };
    };
  }]
, fonts ? with config.theme.fonts; {
    names = lib.flatten [
      gui.name
      icons.name
    ];
    style = "Regular";
    size = 8.0;
  }
, extraBindings ? { }
, extraWindowOptions ? { }
, extraFocusOptions ? { }
, extraModes ? { }
, extraConfig ? ""
, workspaces ? [
    {
      ws = 1;
      name = "1:  ";
    }
    {
      ws = 2;
      name = "2:  ";
    }
    {
      ws = 3;
      name = "3:  ";
    }
    {
      ws = 4;
      name = "4:  ";
    }
    {
      ws = 5;
      name = "5:  ";
    }
    {
      ws = 6;
      name = "6:  ";
    }
    {
      ws = 7;
      name = "7:  ";
    }
    {
      ws = 8;
      name = "8:  ";
    }
    {
      ws = 9;
      name = "9:  ";
    }
    {
      ws = 0;
      name = "10:  ";
    }
  ]
}:
let
  # Modes
  powerManagementMode =
    " : Screen [l]ock, [e]xit, [s]uspend, [h]ibernate, [R]eboot, [S]hutdown";
  resizeMode = " : [h]  , [j]  , [k]  , [l] ";

  # Helpers
  mapDirection = { prefixKey ? null, leftCmd, downCmd, upCmd, rightCmd }:
    with lib.strings; {
      # Arrow keys
      "${optionalString (prefixKey != null) "${prefixKey}+"}Left" = leftCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}Down" = downCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}Up" = upCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}Right" = rightCmd;
      # Vi-like keys
      "${optionalString (prefixKey != null) "${prefixKey}+"}h" = leftCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}j" = downCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}k" = upCmd;
      "${optionalString (prefixKey != null) "${prefixKey}+"}l" = rightCmd;
    };

  mapDirectionDefault = { prefixKey ? null, prefixCmd }:
    (mapDirection {
      inherit prefixKey;
      leftCmd = "${prefixCmd} left";
      downCmd = "${prefixCmd} down";
      upCmd = "${prefixCmd} up";
      rightCmd = "${prefixCmd} right";
    });

  mapWorkspacesStr = with builtins;
    with lib.strings;
    { workspaces, prefixKey ? null, prefixCmd }:
    (concatStringsSep "\n" (map
      ({ ws, name }:
        ''
          bindsym ${optionalString (prefixKey != null) "${prefixKey}+"}${
            toString ws
          } ${prefixCmd} "${name}"'')
      workspaces));
in
{
  helpers = { inherit mapDirection mapDirectionDefault mapWorkspacesStr; };

  config = {
    inherit bars fonts modifier menu terminal;

    colors = with config.theme.colors; {
      background = base07;
      focused = {
        background = base0D;
        border = base0D;
        childBorder = base0C;
        indicator = base0D;
        text = base00;
      };
      focusedInactive = {
        background = base01;
        border = base01;
        childBorder = base01;
        indicator = base03;
        text = base05;
      };
      placeholder = {
        background = base00;
        border = base00;
        childBorder = base00;
        indicator = base00;
        text = base05;
      };
      unfocused = {
        background = base00;
        border = base01;
        childBorder = base01;
        indicator = base01;
        text = base05;
      };
      urgent = {
        background = base08;
        border = base08;
        childBorder = base08;
        indicator = base08;
        text = base00;
      };
    };

    keybindings = ({
      "${modifier}+Return" = "exec ${terminal}";
      "${modifier}+Shift+q" = "kill";
      "${alt}+F4" = "kill";

      "${modifier}+n" = "exec ${browser}";
      "${modifier}+m" = "exec ${fileManager}";

      "${modifier}+d" = "exec ${menu}";

      "${modifier}+f" = "fullscreen toggle";
      "${modifier}+v" = "split v";
      "${modifier}+b" = "split h";

      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";

      "${modifier}+semicolon" = "focus mode_toggle";
      "${modifier}+Shift+semicolon" = "floating toggle";

      "${modifier}+a" = "focus parent";

      "${modifier}+Shift+minus" = "move scratchpad";
      "${modifier}+minus" = "scratchpad show";

      "${modifier}+r" = ''mode "${resizeMode}"'';
      "${modifier}+Escape" = ''mode "${powerManagementMode}"'';

      "${modifier}+Shift+c" = "reload";
      "${modifier}+Shift+r" = "restart";

      "XF86AudioRaiseVolume" =
        "exec --no-startup-id ${pamixer} --set-limit 150 --allow-boost -i 5";
      "XF86AudioLowerVolume" =
        "exec --no-startup-id ${pamixer} --set-limit 150 --allow-boost -d 5";
      "XF86AudioMute" =
        "exec --no-startup-id ${pamixer} --toggle-mute";
      "XF86AudioMicMute" =
        "exec --no-startup-id ${pamixer} --toggle-mute --default-source";

      "XF86MonBrightnessUp" = "exec --no-startup-id ${light} -A 5%";
      "XF86MonBrightnessDown" = "exec --no-startup-id ${light} -U 5%";

      "XF86AudioPlay" = "exec --no-startup-id ${playerctl} play-pause";
      "XF86AudioStop" = "exec --no-startup-id ${playerctl} stop";
      "XF86AudioNext" = "exec --no-startup-id ${playerctl} next";
      "XF86AudioPrev" = "exec --no-startup-id ${playerctl} previous";

      "Print" = "exec --no-startup-id ${fullScreenShot}";
      "Shift+Print" = "exec --no-startup-id ${areaScreenShot}";

      "Ctrl+escape" = "exec ${dunstctl} close";
      "Ctrl+Shift+escape" = "exec ${dunstctl} close-all";
    } // (mapDirectionDefault {
      prefixKey = modifier;
      prefixCmd = "focus";
    }) // (mapDirectionDefault {
      prefixKey = "${modifier}+Shift";
      prefixCmd = "move";
    }) // (mapDirectionDefault {
      prefixKey = "Ctrl+${alt}";
      prefixCmd = "move workspace to output";
    }) // extraBindings);

    modes =
      let
        exitMode = {
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      in
      {
        ${resizeMode} = (mapDirection {
          leftCmd = "resize shrink width 10px or 10ppt";
          downCmd = "resize grow height 10px or 10ppt";
          upCmd = "resize shrink height 10px or 10ppt";
          rightCmd = "resize grow width 10px or 10ppt";
        }) // exitMode;
        ${powerManagementMode} = {
          l = "mode default, exec loginctl lock-session";
          e = "mode default, exec loginctl terminate-session $XDG_SESSION_ID";
          s = "mode default, exec systemctl suspend";
          h = "mode default, exec systemctl hibernate";
          "Shift+r" = "mode default, exec systemctl reboot";
          "Shift+s" = "mode default, exec systemctl poweroff";
        } // exitMode;
      } // extraModes;

    workspaceAutoBackAndForth = true;
    workspaceLayout = "tabbed";

    window = {
      border = 1;
      hideEdgeBorders = "smart";
      titlebar = false;
    } // extraWindowOptions;

    focus = { followMouse = false; } // extraFocusOptions;
  };

  # Until this issue is fixed we need to map workspaces directly to config file
  # https://github.com/nix-community/home-manager/issues/695
  extraConfig =
    let
      workspaceStr = (builtins.concatStringsSep "\n" [
        (mapWorkspacesStr {
          inherit workspaces;
          prefixKey = modifier;
          prefixCmd = "workspace number";
        })
        (mapWorkspacesStr {
          inherit workspaces;
          prefixKey = "${modifier}+Shift";
          prefixCmd = "move container to workspace number";
        })
      ]);
    in
    ''
      ${workspaceStr}
      ${extraConfig}
    '';
}
