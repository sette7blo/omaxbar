# Changelog

All notable changes to Omaxbar will be documented here.
Versions follow [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`

- **MAJOR** — breaking changes (e.g. plugin id or config format changes that need a reinstall)
- **MINOR** — new features, backwards compatible
- **PATCH** — bug fixes, visual tweaks

---

## [Unreleased]

- Added this changelog and a CI workflow. Pushes and pull requests are linted with shellcheck and the manifest is validated; a version tag must match `manifest.json` and creates the GitHub Release from this file.

## [v0.4.0] — 2026-11-13

- The popover runs in an isolated webapp profile, so it no longer shares a browser instance with your regular windows.
- Foreign windows that land in the popover slot are moved out of it.
- The bar widget tracks the real popover state instead of assuming it from previous toggles.

## [v0.3.0] — 2026-11-06

- Renamed to Omaxbar, refreshed the description and added a preview image.
- The floating-window rule is scoped to the configured URL, so other webapps are not made floating.

## [v0.2.1] — 2026-11-06

- The bar widget bootstraps itself on first load by running `install.sh --if-needed`, so installing with `omarchy plugin add` needs no extra step. The installer exits silently when everything is already wired.

## [v0.2.0] — 2026-11-06

- **Breaking:** the plugin id is now `io.github.sette7blo.omaxbar`. Existing installs must uninstall the old plugin and reinstall from this repo.
- **Breaking:** removed the Open X launcher, which Chromium's single-instance handling made unreliable. Right-click still opens `config.sh`.
- **Breaking:** removed the DOM-scraped notification counter and its watcher panel.
- URL, workspace and popover size are configurable in `config.sh`.

## [v0.1.2] — 2026-11-03

- Hardened notification count scraping with fallback selectors, and kept X's `20+` state instead of showing `20`.
- `install.sh` fails fast when `omarchy-launch-webapp` or `omarchy-cmd-default-browser` is missing.

## [v0.1.1] — 2026-11-02

- The README uses the standard `omarchy plugin add` install flow, and `install.sh` skips the enable step when the plugin is already enabled.

## [v0.1.0] — 2026-11-02

- Initial release.

[Unreleased]: https://github.com/sette7blo/omaxbar/compare/v0.4.0...HEAD
[v0.4.0]: https://github.com/sette7blo/omaxbar/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/sette7blo/omaxbar/compare/v0.2.1...v0.3.0
[v0.2.1]: https://github.com/sette7blo/omaxbar/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/sette7blo/omaxbar/compare/v0.1.2...v0.2.0
[v0.1.2]: https://github.com/sette7blo/omaxbar/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/sette7blo/omaxbar/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/sette7blo/omaxbar/releases/tag/v0.1.0
