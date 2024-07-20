{
  writeShellApplication,
  hyprland,
  jq,
}:

writeShellApplication {
  name = "hyprtabs";

  runtimeInputs = [
    hyprland
    jq
  ];

  text = # bash
    ''
      # Avoid unicode for speed-up
      LC_ALL=C
      LANG=C

      # Get current active window properties
      activewindow="$(hyprctl -j activewindow)"

      # We are in a group already
      if jq -cr --exit-status '.grouped | length > 0' <<< "$activewindow"; then
        # Ungroup current window group and swap with master (when using master layout)
        hyprctl --batch "dispatch togglegroup; dispatch layoutmsg swapwithmaster master;"
      else
        declare -a windows
        address="$(jq -cr '.address' <<< "$activewindow")"
        activeworkspace_id="$(hyprctl activeworkspace -j | jq -cr '.id')"
        # Get all windows
        mapfile -t windows < <(
          hyprctl clients -j |
          jq -cr ".[] | select(.workspace.id == $activeworkspace_id) | .address"
        )

        # Only one window, let's toggle a group
        if [[ "''${#windows[@]}" -eq 1 ]]; then
          hyprctl dispatch togglegroup
        else
          declare -a batch_args window_args
          for window in "''${windows[@]}"; do
            # Move each window and try to group them using all directions
            window_args+=(
              "dispatch focuswindow address:$window;"
              "dispatch moveintogroup l;"
              "dispatch moveintogroup r;"
              "dispatch moveintogroup u;"
              "dispatch moveintogroup d;"
            )
          done

          # Group the first window
          batch_args+=("dispatch togglegroup;")

          # Group all other windows twice
          # Once isn't enough in case of very "deep" layouts
          batch_args+=("''${window_args[@]}" "''${window_args[@]}")

          # Focus the original window at the very end
          batch_args+=("dispatch focuswindow address:$address;")

          # Execute the grouping using hyprctl --batch for performance
          hyprctl --batch "''${batch_args[*]}"
        fi
      fi
    '';
}
