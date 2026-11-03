# Changelog

All notable changes to triforge are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html): a `fix:` bumps the patch version, a `feat:` the minor
version, and a change that breaks existing installations the major version.

## [Unreleased]

## [1.0.0] - 2026-11-03

First release.

### Installation
- One-line installer (`bootstrap`): clones triforge into `~/.local/share/triforge`, then runs the installer.
  Running it again updates the clone; `TRIFORGE_REF` installs a given release tag or branch.
- Root `install` script: interactive checklist (or component names) to install `i3`, `tmux` and `alacritty`,
  `--update` to refresh configuration files only, `--yes` for non-interactive runs, `--version`.
- Each component keeps its own standalone installer, and configuration is always installed in the home of the
  user who ran `sudo`.

### i3
- i3-gnome environment with i3blocks (built from a pinned commit) and vendored i3-gnome session files.
- 16 color themes, switchable with `$mod+Shift+t`.
- Status bar blocks: top process, Docker containers, volume, memory, battery, clock with calendar, date.
- Shortcuts help menu on `$mod+Shift+,` (`$mod+?` on AZERTY), generated from `# help:` comments in the config.
- English and French messages for menus and scripts, following the user's locale.
- Monitor layouts with autorandr, selectable with `$mod+p`; workspaces pinned to outputs.
- Screen lock after inactivity and before suspend (xss-lock + i3lock-fancy).
- picom compositor (vsync against tearing, proper GTK4 rounded corners).
- Hack Nerd Font installed from a pinned upstream release.
- Default triforge wallpaper.

### tmux
- tmux with TPM, tmux-sensible, tmux-continuum and the maintained
  [tmux-resurrect fork](https://github.com/nmetahri/tmux-resurrect) (fixes panes restored to `$HOME`).

### Alacritty
- Alacritty configuration in TOML format (Alacritty 0.13+).

### Continuous integration
- shellcheck on every installer and test script.
- Every component installed and verified in fresh `ubuntu:24.04` and `debian:stable-slim` containers, including
  the one-line installer and `--update`.

[Unreleased]: https://github.com/nmetahri/triforge/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/nmetahri/triforge/releases/tag/v1.0.0
