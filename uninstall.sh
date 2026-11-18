#!/usr/bin/env bash
# Reverse what install.sh wrote. Leaves the plugin directory behind.

set -euo pipefail

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="io.github.sette7blo.omaxbar"
HYPRLAND_LUA="$HOME/.config/hypr/hyprland.lua"
BEGIN="-- BEGIN $PLUGIN_NAME plugin (managed by install.sh)"
END="-- END $PLUGIN_NAME plugin"

# shellcheck source=bin/_common.sh
source "$PLUGIN_DIR/bin/_common.sh"

log() { printf '[omaxbar] %s\n' "$*"; }

# Removes only the exact block install.sh appended. If the markers are missing,
# repeated, or anything else sits between them, the file is left untouched.
remove_hyprland_requires() {
  [[ -f $HYPRLAND_LUA ]] || return 0
  grep -qF -- "$BEGIN" "$HYPRLAND_LUA" || return 0
  local plugin_path="/.config/omarchy/plugins/$PLUGIN_NAME"
  local line1="dofile(os.getenv(\"HOME\") .. \"$plugin_path/autostart.lua\")"
  local line2="dofile(os.getenv(\"HOME\") .. \"$plugin_path/hypr.lua\")"
  local tmp; tmp=$(mktemp)
  if ! awk -v b="$BEGIN" -v e="$END" -v l1="$line1" -v l2="$line2" '
    { lines[NR] = $0 }
    $0 == b { nb++; start = NR }
    $0 == e { ne++; stop = NR }
    END {
      if (nb != 1 || ne != 1 || stop != start + 3) exit 1
      if (lines[start + 1] != l1 || lines[start + 2] != l2) exit 1
      # Also drop the blank line install.sh put before the block.
      if (start > 1 && lines[start - 1] == "") start--
      for (i = 1; i <= NR; i++) if (i < start || i > stop) print lines[i]
    }
  ' "$HYPRLAND_LUA" > "$tmp"; then
    rm -f "$tmp"
    log "WARNING: the plugin block in $HYPRLAND_LUA is not the one install.sh wrote"
    log "         (a marker is missing or repeated, or it was edited). Left the file"
    log "         unchanged; remove the lines between these markers by hand:"
    log "           $BEGIN"
    log "           $END"
    return 0
  fi
  log "removing plugin block from $HYPRLAND_LUA"
  # Write in place so a symlinked hyprland.lua and its permissions are kept.
  cat "$tmp" > "$HYPRLAND_LUA"
  rm -f "$tmp"
}

disable_widget() {
  omarchy plugin disable "$PLUGIN_NAME" 2>&1 | sed 's/^/[omaxbar] /' || true
}

# Closes only windows of the browser running on the plugin's own profile; a
# same-URL webapp the user opened elsewhere is left alone.
kill_webapp() {
  local addr pid
  while read -r addr pid; do
    owns_pid "$pid" || continue
    hyprctl dispatch "hl.dsp.window.close({window=\"address:$addr\"})" >/dev/null || true
    log "closed the omaxbar webapp window"
  done < <(class_windows)
}

remove_hyprland_requires
disable_widget
kill_webapp
hyprctl reload >/dev/null && log "reloaded hyprland config"
log "done. Plugin dir still at $PLUGIN_DIR — delete manually to fully wipe."
