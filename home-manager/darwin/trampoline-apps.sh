# Utilities not in nixpkgs.
plutil="/usr/bin/plutil"
killall="/usr/bin/killall"
osacompile="/usr/bin/osacompile"

copyable_app_props=(
  "CFBundleDevelopmentRegion"
  "CFBundleDocumentTypes"
  "CFBundleGetInfoString"
  "CFBundleIconFile"
  "CFBundleIdentifier"
  "CFBundleInfoDictionaryVersion"
  "CFBundleName"
  "CFBundleShortVersionString"
  "CFBundleURLTypes"
  "NSAppleEventsUsageDescription"
  "NSAppleScriptEnabled"
  "NSDesktopFolderUsageDescription"
  "NSDocumentsFolderUsageDescription"
  "NSDownloadsFolderUsageDescription"
  "NSPrincipalClass"
  "NSRemovableVolumesUsageDescription"
  "NSServices"
  "UTExportedTypeDeclarations"
)

function sync_icons() {
  local from="$1"
  local to="$2"
  from_resources="$from/Contents/Resources/"
  to_resources="$to/Contents/Resources/"

  find "$to_resources" -name "*.icns" -delete
  rsync --include "*.icns" --exclude "*" --recursive "$from_resources" "$to_resources"
}

function copy_paths() {
  local from="$1"
  local to="$2"
  local paths=("${@:3}")

  keys=$(jq -n '$ARGS.positional' --args "${paths[@]}")
  jqfilter="to_entries |[.[]| select(.key as \$item| \$keys | index(\$item) >= 0) ] | from_entries"

  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT

  pushd $temp_dir >/dev/null

  cp "$from" "orig"
  chmod u+w "orig"

  cp "$to" "bare-wrapper"
  chmod u+w "bare-wrapper"

  $plutil -convert json -- "orig"
  $plutil -convert json -- "bare-wrapper"
  jq --argjson keys "$keys" "$jqfilter" <"orig" >"filtered"
  cat "bare-wrapper" "filtered" | jq -s add >"final"
  $plutil -convert xml1 -- "final"

  cp "final" "$to"
  popd >/dev/null
}

function sync_dock() {
  # Make sure all environment variables are cleared that might affect dockutil
  unset SUDO_USER

  # Array of applications to sync
  declare -a apps=("$@")

  # Iterate through each provided app
  for app_path in "${apps[@]}"; do
    if [ -d "$app_path" ]; then
      # Extract the name of the app from the path
      app_name=$(basename "$app_path")
      app_name=${app_name%.*} # Remove the '.app' extension
      resolved_path=$(realpath "$app_path")

      # Find the current Dock item for the app, if it exists
      current_dock_item=$(dockutil --list --no-restart | grep "$app_name.app" | awk -F "\t" '{print $1}' || echo "")

      if [ -n "$current_dock_item" ]; then
        # The app is currently in the Dock, attempt to replace it
        echo "Updating $app_name in Dock..."
        dockutil --add "$resolved_path" --replacing "$current_dock_item" --no-restart
      else
        # The app is not in the Dock; you might choose to add it or do nothing
        echo "$app_name is not currently in the Dock."
      fi
    else
      echo "Warning: Provided path $app_path is not valid."
    fi
  done

  # Restart the Dock to apply changes
  $killall Dock
}

function mktrampoline() {
  local app="$1"
  local trampoline="$2"

  if [[ ! -d $app ]]; then
    echo "app path is not directory."
    return 1
  fi

  cmd="do shell script \"open '$app'\""
  $osacompile -o "$trampoline" -e "$cmd"
  sync_icons "$app" "$trampoline"
  copy_paths "$(realpath "$app/Contents/Info.plist")" "$(realpath "$trampoline/Contents/Info.plist")" "${copyable_app_props[@]}"
}

function sync_trampolines() {
  [[ ! -d "$1" ]] && echo "Source directory does not exist" && return 1

  if [[ -d "$2" ]]; then
    rm -rf "$2"
  fi
  mkdir -p "$2"

  apps=("$1"/*.app)

  for app in "${apps[@]}"; do
    trampoline="$2/$(basename "$app")"
    mktrampoline "$app" "$trampoline"
  done
  sync_dock "${apps[@]}"
}
