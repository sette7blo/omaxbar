# x-notifications — Omarchy plugin

A bar widget that toggles a hidden X web app popover on click. The 𝕏
icon in the bar opens and closes the popover; focusing another window
auto-hides it.

The plugin keeps the `x-notifications` name for compatibility with
earlier installs; the unread-count scraping it originally shipped has
been removed.

## Requirements

- Omarchy (Hyprland + QuickShell bar).
- A Chromium-based default browser: Brave, Chrome, Chromium, Edge, Opera,
  Vivaldi, or Helium. Firefox is not supported (no `--app=` with a stable
  WM_CLASS).

## Install

```sh
omarchy plugin add https://github.com/sette7blo/omarchy-x-notifications --enable
~/.config/omarchy/plugins/x-notifications/install.sh
```

The first command is the standard Omarchy flow: clone into
`~/.config/omarchy/plugins/x-notifications` and register the bar widget.
The second command does the extras `omarchy plugin add` doesn't handle.
Both commands are idempotent, so re-running them is safe.

`install.sh`:

1. Seeds `config.sh` from `config.sh.example` on first run; leaves it
   alone on subsequent runs.
2. Regenerates `hypr.lua` and `autostart.lua` from the `.tmpl` files
   using values from `config.sh`.
3. Verifies a Chromium-based default browser.
4. Appends `require()` lines for `hypr.lua` and `autostart.lua` to
   `~/.config/hypr/hyprland.lua`, guarded by sentinel comments.
5. Installs and enables the user systemd service that hides the popover
   when focus leaves it.
6. Enables the bar widget via `omarchy plugin enable` (skipped if you
   already passed `--enable` above).
7. Launches the hidden X webapp so you don't have to log out.

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

After editing, re-run `install.sh` to regenerate `hypr.lua` and
`autostart.lua`, then close the running X popover window so the next
toggle re-launches it with the new URL.

## Uninstall

```sh
~/.config/omarchy/plugins/x-notifications/uninstall.sh
```

Reverses each install step. Does not delete the plugin directory.

## How it works

- `BarWidget.qml` — Omarchy QML widget. 𝕏 button that spawns
  `bin/x-notifications-toggle` on click.
- `bin/x-notifications-toggle` — toggles `special:xnotif`, launching the
  webapp first if needed.
- `bin/x-notifications-watcher` — listens on the Hyprland event socket and
  auto-hides the popover when focus moves away.
- `hypr.lua` / `autostart.lua` — **generated** by `install.sh` from the
  sibling `.tmpl` files, using values from `config.sh`. Don't edit the
  generated files; edit the template or `config.sh` and re-run install.

## Advanced

The matched WM_CLASS regex is `-x\.com__.*-Default$` (in `bin/_common.sh`),
which matches any x.com path on any Chromium derivative. If you point
`URL` at a different host, update `CLASS_RE` to match.
