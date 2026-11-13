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

Any of these works — the widget self-bootstraps on first load:

```sh
# CLI
omarchy plugin add https://github.com/sette7blo/omaxbar --enable
```

Or install through **omaplug** (GUI) and pick `omaxbar` from the list.

**What "self-bootstrap" means:** the first time `BarWidget.qml` loads, it
runs `install.sh --if-needed`, which **appends two `dofile()` lines to
`~/.config/hypr/hyprland.lua`** (inside a sentinel block), generates
`hypr.lua`/`autostart.lua` from templates, runs `hyprctl reload`, and
launches the hidden webapp. Subsequent loads are no-ops. If you'd rather
do it explicitly, run the installer yourself:

```sh
~/.config/omarchy/plugins/io.github.sette7blo.omaxbar/install.sh
```

Both paths are idempotent and safe to re-run.

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

## Separate browser profile

The webapp runs in its own browser profile at
`~/.local/share/omaxbar/browser` (a separate `--user-data-dir`), so it is a
separate browser process. Links opened by other apps or plugins always go
to your regular browser and never land in the popover. The first time you
open the popover after upgrading from 0.3 or earlier, you need to log in
to X once; the old shared-profile X window is closed automatically.

While the popover has focus, Hyprland would place any newly opened window
inside it. The widget watches for this, moves the window to the workspace
underneath, and closes the popover.

## Uninstall

```sh
~/.config/omarchy/plugins/io.github.sette7blo.omaxbar/uninstall.sh
```

Removes the hyprland.lua plugin block, disables the widget, and closes
the webapp window. Does not delete the plugin directory or the browser
profile at `~/.local/share/omaxbar/browser`.

## How it works

- `BarWidget.qml` — Omarchy QML widget. Left-click runs
  `bin/omaxbar-toggle`; right-click runs `bin/omaxbar-config`. The icon
  state follows Hyprland's `activespecial` events, so it stays correct
  when the popover is closed by a keybind or workspace switch.
- `bin/omaxbar-toggle` — shows or hides `special:xnotif` based on its
  real state, launching the webapp first if it isn't running. Also
  `status` (prints 1/0) and `evict <address>` (moves a foreign window
  out of the popover).
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
