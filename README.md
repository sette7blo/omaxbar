# omaxbar — Omarchy plugin

A bar widget that toggles a floating X web app popover. Left-click the
𝕏 icon to show/hide the popover; right-click opens `config.sh` in your
default editor. The popover stays visible until you press the 𝕏 button
again.

## Requirements

- Omarchy (Hyprland + QuickShell bar).
- A Chromium-based default browser: Brave, Chrome, Chromium, Edge, Opera,
  Vivaldi, or Helium. Firefox is not supported (no `--app=` with a stable
  WM_CLASS).

## Install

```sh
omarchy plugin add https://github.com/sette7blo/omaxbar --enable
~/.config/omarchy/plugins/io.github.sette7blo.omaxbar/install.sh
```

The first command is the standard Omarchy flow: clone into
`~/.config/omarchy/plugins/io.github.sette7blo.omaxbar` and register the bar widget.
The second command does the extras `omarchy plugin add` doesn't handle.
Both commands are idempotent, so re-running them is safe.

`install.sh`:

1. Seeds `config.sh` from `config.sh.example` on first run; leaves it
   alone on subsequent runs.
2. Regenerates `hypr.lua` and `autostart.lua` from the `.tmpl` files
   using values from `config.sh`.
3. Verifies a Chromium-based default browser.
4. Appends `dofile()` lines for `hypr.lua` and `autostart.lua` to
   `~/.config/hypr/hyprland.lua`, guarded by sentinel comments. (We use
   `dofile` instead of `require` because the plugin id contains dots.)
5. Enables the bar widget via `omarchy plugin enable` (skipped if you
   already passed `--enable` above).
6. Launches the hidden X webapp so you don't have to log out.

## Config

User-editable settings live in `config.sh` (seeded from
`config.sh.example` on first install, then gitignored so `git pull`
preserves your values):

| Variable    | Default               | Effect                                        |
|-------------|-----------------------|-----------------------------------------------|
| `URL`       | `https://x.com/home`  | Page the hidden webapp loads.                 |
| `WORKSPACE` | `xnotif`              | Hyprland special workspace name.              |
| `WIDTH`     | `440`                 | Popover width in px.                          |
| `HEIGHT`    | `680`                 | Popover height in px.                         |

Right-click the 𝕏 button to edit `config.sh` directly. After editing,
re-run `install.sh` to regenerate `hypr.lua` and `autostart.lua`, then
close the running X popover window so the next toggle re-launches it
with the new URL/size.

## Uninstall

```sh
~/.config/omarchy/plugins/io.github.sette7blo.omaxbar/uninstall.sh
```

Removes the hyprland.lua plugin block, disables the widget, and closes
the webapp window. Does not delete the plugin directory.

## How it works

- `BarWidget.qml` — Omarchy QML widget. Left-click runs
  `bin/omaxbar-toggle show|hide`; right-click runs
  `bin/omaxbar-config`.
- `bin/omaxbar-toggle` — toggles `special:xnotif` via `hyprctl`,
  launching the webapp first if it isn't running.
- `bin/omaxbar-config` — opens `config.sh` via
  `omarchy-launch-config-editor` (your default editor in your default
  terminal).
- `hypr.lua` / `autostart.lua` — **generated** by `install.sh` from the
  sibling `.tmpl` files, using values from `config.sh`. Don't edit the
  generated files; edit the template or `config.sh` and re-run install.

## Advanced

The matched WM_CLASS regex is `-x\.com__.*-Default$` (in `bin/_common.sh`),
which matches any x.com path on any Chromium derivative. If you point
`URL` at a different host, update `CLASS_RE` to match.

The popover uses a Hyprland special workspace without `special_fallthrough`,
so the popover stays visible until you press 𝕏 again. Clicks on the area
outside the popover (while it's shown) are blocked — close the popover
first to interact with background windows.
