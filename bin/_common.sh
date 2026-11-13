# Sourced by the sibling scripts.

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Defaults — overridable in config.sh. WIDTH/HEIGHT live in config.sh only;
# they are consumed by install.sh when it renders hypr.lua and never by the
# runtime scripts that source this file.
URL="https://x.com/home"
WORKSPACE="xnotif"

# shellcheck source=/dev/null
[[ -f "$PLUGIN_DIR/config.sh" ]] && source "$PLUGIN_DIR/config.sh"

# CLASS_RE is derived from $URL so it matches only the omaxbar webapp, not other
# x.com windows the user may launch (e.g. Omarchy's default SUPER+SHIFT+X).
# Chromium maps URL path to WM_CLASS: /home → __home, / → __, /a/b → __a_b.
__url_stripped=${URL#*://}
__url_host=${__url_stripped%%/*}
if [[ $__url_stripped == */* ]]; then
  __url_path=${__url_stripped#*/}
  __url_path=${__url_path//\//_}
else
  __url_path=""
fi
__class_suffix="${__url_host}__${__url_path}"
CLASS_RE="-${__class_suffix//./\\.}-Default\$"
unset __url_stripped __url_host __url_path __class_suffix

# The webapp runs in its own browser profile. A webapp launched in the shared
# profile becomes the browser's main process, so links from other apps get
# handed to it; a separate --user-data-dir keeps it exclusive to $URL.
PROFILE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omaxbar/browser"

# Prints "<address> <pid>" for every window whose class matches the webapp.
class_windows() {
  hyprctl clients -j 2>/dev/null | \
    jq -r --arg re "$CLASS_RE" '.[] | select(.class | test($re)) | "\(.address) \(.pid)"'
}

# True if the pid is a browser running on the omaxbar profile. Chromium
# rewrites its argv as one space-joined string, so match on spaces too.
owns_pid() {
  local cmd
  cmd=$(tr '\0' ' ' < "/proc/$1/cmdline" 2>/dev/null) || return 1
  [[ " $cmd " == *" --user-data-dir=$PROFILE_DIR "* ]]
}
