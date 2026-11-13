#!/usr/bin/env bash
# Idempotent installer for the omaxbar Omarchy plugin.

set -euo pipefail

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="io.github.sette7blo.omaxbar"
HYPRLAND_LUA="$HOME/.config/hypr/hyprland.lua"
BEGIN="-- BEGIN $PLUGIN_NAME plugin (managed by install.sh)"
END="-- END $PLUGIN_NAME plugin"

log() { printf '[omaxbar] %s\n' "$*"; }

# --if-needed: bail out silently if everything looks already wired.
# Used by BarWidget.qml to self-bootstrap after omaplug / `omarchy plugin add`.
if [[ ${1:-} == --if-needed ]]; then
  if [[ -f $PLUGIN_DIR/hypr.lua && -f $PLUGIN_DIR/autostart.lua && -f $PLUGIN_DIR/config.sh ]] \
     && grep -qF -- "$BEGIN" "$HYPRLAND_LUA" 2>/dev/null; then
    exit 0
  fi
fi

seed_config() {
  if [[ ! -f $PLUGIN_DIR/config.sh ]]; then
    cp "$PLUGIN_DIR/config.sh.example" "$PLUGIN_DIR/config.sh"
    log "seeded config.sh from config.sh.example"
  fi
  # shellcheck source=/dev/null
  source "$PLUGIN_DIR/config.sh"
  : "${URL:?URL must be set in config.sh}"
  : "${WORKSPACE:?WORKSPACE must be set in config.sh}"
  : "${WIDTH:?WIDTH must be set in config.sh}"
  : "${HEIGHT:?HEIGHT must be set in config.sh}"
}

# Chromium derives WM_CLASS from --app= URLs as "<host>__<path with / → _>".
#   https://x.com/home          → x.com__home
#   https://x.com/              → x.com__
#   https://x.com/compose/post  → x.com__compose_post
url_to_class_suffix() {
  local url=$1 stripped host path
  stripped=${url#*://}
  host=${stripped%%/*}
  if [[ $stripped == */* ]]; then
    path=${stripped#*/}
    path=${path//\//_}
  else
    path=""
  fi
  printf '%s__%s' "$host" "$path"
}

generate_lua() {
  local x_offset=$((WIDTH + 12))
  local class_suffix class_suffix_re tmpl out
  class_suffix=$(url_to_class_suffix "$URL")
  # Escape dots as [.] character class — survives sed replacement without needing
  # backslash doubling, and parses fine as a regex inside the Lua string literal.
  class_suffix_re=${class_suffix//./[.]}
  for name in hypr autostart; do
    tmpl="$PLUGIN_DIR/$name.lua.tmpl"
    out="$PLUGIN_DIR/$name.lua"
    sed -e "s|\${WIDTH}|$WIDTH|g" \
        -e "s|\${HEIGHT}|$HEIGHT|g" \
        -e "s|\${WORKSPACE}|$WORKSPACE|g" \
        -e "s|\${URL}|$URL|g" \
        -e "s|\${X_OFFSET}|$x_offset|g" \
        -e "s|\${CLASS_SUFFIX_RE}|$class_suffix_re|g" \
        -e "s|\${PLUGIN_DIR}|$PLUGIN_DIR|g" \
        "$tmpl" > "$out"
    log "generated $(basename "$out") from $(basename "$tmpl")"
  done
}

check_browser() {
  local b
  b=$(omarchy-cmd-default-browser 2>/dev/null || true)
  case "$b" in
    brave*|google-chrome*|chromium*|microsoft-edge*|opera*|vivaldi*|helium*)
      log "default browser: $b (ok)" ;;
    *)
      log "WARNING: default browser '$b' is not Chromium-based. The popover"
      log "         needs --app= with a stable WM_CLASS. Install a Chromium"
      log "         browser (brave/chrome/chromium/edge/opera/vivaldi) and set it as default." ;;
  esac
}

install_hyprland_requires() {
  [[ -f $HYPRLAND_LUA ]] || { log "ERROR: $HYPRLAND_LUA not found"; exit 1; }
  if grep -qF -- "$BEGIN" "$HYPRLAND_LUA"; then
    log "hyprland.lua already wired (skip)"
    return
  fi
  log "appending plugin requires to $HYPRLAND_LUA"
  # dofile (not require) because PLUGIN_NAME contains dots, which Lua's
  # require treats as path separators.
  cat >> "$HYPRLAND_LUA" <<EOF

$BEGIN
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/$PLUGIN_NAME/autostart.lua")
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/$PLUGIN_NAME/hypr.lua")
$END
EOF
}

enable_widget() {
  # omarchy-shell can be transiently busy; retry the already-enabled check.
  for _ in 1 2 3 4 5; do
    if omarchy plugin list --json 2>/dev/null | \
       jq -e --arg id "$PLUGIN_NAME" '.[] | select(.id == $id) | .enabled' >/dev/null; then
      log "widget already enabled (skip)"
      return
    fi
    sleep 0.5
  done
  omarchy plugin enable "$PLUGIN_NAME" right 2>&1 | sed 's/^/[omaxbar] /' || \
    log "WARNING: enable failed (shell busy?). Re-run install.sh or run: omarchy plugin enable $PLUGIN_NAME right"
}

launch_webapp_now() {
  log "starting X webapp (hidden in special:$WORKSPACE)"
  "$PLUGIN_DIR/bin/omaxbar-toggle" ensure >/dev/null 2>&1 &
  disown
}

for dep in jq hyprctl sed omarchy-launch-webapp omarchy-cmd-default-browser; do
  command -v "$dep" >/dev/null || { log "ERROR: missing dependency: $dep"; exit 1; }
done

log "plugin dir: $PLUGIN_DIR"
seed_config
generate_lua
check_browser
install_hyprland_requires
enable_widget
hyprctl reload >/dev/null && log "reloaded hyprland config"
launch_webapp_now
log "done. Click 𝕏 to toggle the popover; right-click opens config.sh."
