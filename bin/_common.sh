# Sourced by the sibling scripts.

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Chromium's --app= produces WM_CLASS ending in -x.com__<path>-Default for
# any brave/chrome/chromium/edge/opera/vivaldi derivative.
CLASS_RE='-x\.com__.*-Default$'

# Defaults — overridable in config.sh. WIDTH/HEIGHT live in config.sh only;
# they are consumed by install.sh when it renders hypr.lua and never by the
# runtime scripts that source this file.
URL="https://x.com/home"
WORKSPACE="xnotif"

# shellcheck source=/dev/null
[[ -f "$PLUGIN_DIR/config.sh" ]] && source "$PLUGIN_DIR/config.sh"
