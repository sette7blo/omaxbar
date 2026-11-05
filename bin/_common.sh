# Sourced by the sibling scripts.

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Chromium's --app= produces WM_CLASS ending in -x.com__<path>-Default for
# any brave/chrome/chromium/edge/opera/vivaldi derivative. The loose match
# supports pointing URL at /home, /messages, /i/lists/..., etc.
CLASS_RE='-x\.com__.*-Default$'

# Defaults — overridable in config.sh.
URL="https://x.com/home"
WORKSPACE="xnotif"
WIDTH=440
HEIGHT=680

# shellcheck source=/dev/null
[[ -f "$PLUGIN_DIR/config.sh" ]] && source "$PLUGIN_DIR/config.sh"
