# i3-Gnome Environment Setup + My Tmux Config

This repository contains a complete, opinionated setup for an i3-Gnome environment on Debian/Ubuntu-based systems.

It is installed via a single script that handles all package dependencies (like `gdm3`, `gnome-session`, `gnome-keyring`, etc.), builds `i3blocks`, and copies all personal configuration files.

## How to use ?

Each directory is independant so you can install whatever you want.

It is recommended to install and configure packages in that order : 
- I3
- Tmux

## External Dependencies

This setup builds and installs from the following external projects:

- **i3blocks** (https://github.com/vivien/i3blocks) — Status bar for i3
- **i3-gnome** (https://github.com/i3-gnome/i3-gnome.git) — Gnome 3 session integration with i3

Both are automatically cloned, built, and installed by the install script. Check their repositories for license information and updates.

The tmux setup uses [TPM](https://github.com/tmux-plugins/tpm) to install its plugins, including
**tmux-resurrect** from a maintained fork (https://github.com/nmetahri/tmux-resurrect) that bundles
fixes still unmerged upstream (e.g. panes restored to `$HOME` when their title is empty).

## How to install a package ?

### Tmux

All you have to do, in order to install and configure tmux, is :
- Go to package directory (e.g. `cd tmux`)
- Give execution permission to `install`
- Execute `install` as **super user (sudo)**

### I3

All you have to do, in order to install and configure i3-gnome environment, is :
- Go to i3 directory (e.g. `cd i3`)
- Give execution permission to `install.sh`
- Execute `install.sh` as **super user (sudo)**
- Reboot your system and select `i3+gnome` session at login screen
- Login and enjoy your new i3-gnome environment !

## Some commands to know for my i3-gnome environment
`$mod` Refers to the modifier key (super by default)

### General
* `$mod+<Enter>` Open a terminal
* `$mod+d` Open dmenu (text based program launcher)
* `$mod+r` Resize mode (<Esc> or <Enter> to leave resize mode)
* `$mod+shift+r` Restart i3 in place
* `$mod+shift+c` Reload config file
* `$mod+shift+q` Kill window (does normal close if application supports it)

### Windows
* `$mod+w` Tabbed layout
* `$mod+e` Vertical and horizontal layout (switches to and between them)
* `$mod+s` Stacked layout
* `$mod+f` Fullscreen

### Moving Windows
* `$mod+shift+<direction key>` Move window in _direction_ (depends on direction keys settings)
* `$mod+Ctrl+greater` Move window to right output screen
* `$mod+Ctrl+less` Move window to left output screen 

### Brightness keys
* `XF86MonBrightnessUp` Increase brightness
* `XF86MonBrightnessDown` Decrease brightness

### Media keys
* `XF86AudioPlay` Play/Pause
* `XF86AudioPause` Pause/Pause
* `XF86AudioNext` Next
* `XF86AudioPrev` Previous

### Custom key bindings
* `$mod+Shift+e` Open system menu : (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown
* `$mod + p` — Open monitor layout selector (`select_xrandr_profile.bash`, lists autorandr profiles)
  (see [Monitor Profiles](#monitor-profiles-autorandr))
* `$mod+Shift+t` Open theme selector (dmenu with available themes)
* `$mod+b` Choose a background image
* `shift+Print` Take a screenshot on selected area
* `Print` Take a full window screenshot

## Monitor Profiles (autorandr)

Monitor layouts are handled by [autorandr](https://github.com/phillipberndt/autorandr). Each profile stores
an `xrandr` layout plus the fingerprint of the connected screens, so the right layout is picked automatically.
Profiles are machine-specific, so they are **not versioned**: create them on each machine.

### Create a profile
1. Plug in your monitors and arrange them (with `xrandr`, or a GUI such as `arandr`)
2. Save the current layout: `autorandr --save <name>` (e.g. `office`, `home`, `laptop`)
3. Repeat for every setup you use

Profiles are stored in `~/.config/autorandr/<name>/`.

### Use profiles
* At i3 startup, `autorandr --change` loads the profile matching the connected screens
* `$mod + p` opens a dmenu list of your profiles to switch manually
* `autorandr --list` lists profiles, `autorandr --load <name>` loads one from a terminal

### Run something after each switch
autorandr runs `~/.config/autorandr/postswitch` (if executable) after loading a profile. Restarting i3 there
re-applies the workspace-to-output assignments from `workspaces.conf`:

```bash
#!/bin/bash
sleep 1
[ -f ~/.last_wallpaper ] && feh --bg-scale "$(cat ~/.last_wallpaper)" &
i3-msg restart &
```

Workspaces are pinned to outputs in `workspaces.conf` (`DP-1`, `HDMI-1`, then `eDP-1` as fallback).
Adjust these names to your hardware: `xrandr --query` lists them.

## Theme System

This setup includes a dynamic theme switching system that allows you to easily change color schemes.

### Available Themes
1. **Minimaliste** - Clean and minimal color palette
2. **Glassmorphism** - Modern frosted glass aesthetic
3. **Cyberpunk** - Neon-inspired dark theme
4. **Material** - Google Material Design colors
5. **Solarized** - The popular Solarized dark theme
6. **Gruvbox** - Warm, retro-inspired colors
7. **Nord** - Arctic, north-bluish palette
8. **Dracula** - Dark theme with vivid purple and pink accents
9. **Monokai** - Classic high-contrast editor colors
10. **Tokyo Night** - Deep blue night-city palette
11. **Catppuccin Mocha** - Soothing pastel dark theme
12. **Oceanic Next** - Calm ocean-blue tones
13. **Palenight** - Soft purple Material variant
14. **Gotham** - Very dark, low-contrast blue-green
15. **Ayu** - Minimal dark theme with warm accents
16. **Badwolf** - Dark theme with bright, punchy highlights

### How to Switch Themes
Press `$mod+Shift+t` to open the theme selector (dmenu). Choose a theme from the list and it will be immediately applied to:
- i3bar colors and styling
- Window decorations
- All i3 UI elements
- Alacritty terminal colors (automatically synced)

The active theme is managed via a symlink (`colors-active.conf`) that points to the selected theme file. This symlink is automatically created on first installation.

### Adding Custom Themes
To add a custom theme:
1. Create a new `.conf` file in `~/.config/i3/themes/` following this naming pattern: `N-themename.conf` (where N is a number)
2. Define your colors using the following variables:
   ```
   set $bg #1e1e2e
   set $fg #cdd6f4
   set $border-active #89b4fa
   set $border-inactive #45475a
   set $text-urgent #f38ba8
   ```
3. Run `$mod+Shift+t` and select your new theme

## Alacritty Configuration

Alacritty is automatically configured and managed by the installation script.

### Configuration
- Base configuration is located in `~/.config/alacritty/alacritty.toml` (TOML format, Alacritty 0.13+)
- The configuration is synced during installation and updates

### Updating Alacritty Config
When you pull updates from the repository and want to update Alacritty configuration:
```bash
cd i3
sudo ./install --update
```

This will update both i3 and Alacritty configurations to the latest versions.

## How to assign an application to a specific workspace ?

In order to assign an application to a specific workspace, you will need to get it's WM class name, to do so, you can save this alias in your bashrc : 

`alias get-window-class="xprop | grep WM_CLASS | awk '{ print \$4 }'"`

When you execute this command, you will have to select a window and it will display its class name, then you can add something like this in your `~/.config/i3/custom.conf` : 

```
assign [class="Firefox"] $ws3
for_window [class="Firefox"] focus
```  

This will always assign Firefox to workspace 3 and focus it when it is launched.