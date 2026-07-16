# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains configuration files for my Linux desktop.

## Managed Applications

### Terminal & Shell
- **alacritty** - Terminal emulator
- **foot** - Wayland terminal
- **ghostty** - Terminal emulator
- **kitty** - Terminal emulator
- **wezterm** - Terminal emulator
- **fish** - Shell configuration (private)
- **starship** - Shell prompt
- **tmux** - Terminal multiplexer with Catppuccin theme

### Wayland & Desktop
- **niri** - Niri compositor
- **quickshell** - Wayland shell/bar + notification stack
- **fuzzel** - Application launcher

#### Niri keybindings
`Mod` is Super on TTY and Alt when running in a window.

- `Mod+T` — kitty terminal
- `Mod+P` — scratch editor
- `Mod+M` — media/player launcher
- `Mod+Z` / `Mod+Shift+Z` — Zed / Obsidian
- `Mod+Grave` — scratch shell
- `Alt+Tab` — switch windows
- `Mod+D` — app launcher
- `Mod+Shift+D` — Discord
- `Mod+S` — Steam launcher
- `Super+Shift+T` — Thunderbird
- `Mod+B` / `Mod+Shift+B` — Firefox Dev / Beeper
- `Super+Alt+L` — lock screen
- `Mod+G` — ShadowTech
- `Mod+Q` — close window
- `Mod+O` — overview
- `Mod+H/J/K/L` or arrow keys — move focus
- `Mod+Ctrl+H/J/K/L` or arrow keys — move windows/columns
- `Mod+1..9` — switch workspaces
- `Mod+Ctrl+1..9` — move column to workspace
- `Mod+PageUp/PageDown` or `Mod+U/I` — workspace focus
- `Mod+Shift+PageUp/PageDown` or `Mod+Shift+U/I` — move workspace
- `Mod+BracketLeft/BracketRight` — consume/expel window
- `Mod+Comma` / `Mod+Period` — consume/expel window in column
- `Mod+R` / `Mod+Shift+R` / `Mod+Ctrl+R` — column width / window height / reset height
- `Mod+F` / `Mod+Shift+F` / `Mod+Ctrl+F` — maximize / fullscreen / expand column
- `Mod+C` / `Mod+Ctrl+C` — center column(s)
- `Mod+V` / `Mod+Shift+V` — toggle floating / switch focus floating-tiling
- `Mod+W` — tabbed column view
- `Mod+F12` / `Mod+Ctrl+F12` / `Mod+Alt+F12` — screenshots
- `Mod+Escape` — toggle keyboard shortcut inhibition
- `Mod+Shift+E` / `Ctrl+Alt+Delete` — quit
- `Mod+Shift+P` — power off monitors

### Utilities
- **eza** - Modern ls replacement with custom theme
- **mpv** - Media player (private)

### Customization & Scripts
- Custom helper scripts (`~/.local/bin`)
- Custom desktop entries and icons (`~/.local/share/applications`, `~/.local/share/icons`)

### Browsers
- Microsoft Edge flags
- Vivaldi configuration

## Usage

### Install chezmoi and apply dotfiles
```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with this repository
chezmoi init <your-repo-url>

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply
```

### Update dotfiles
```bash
# Add a new file
chezmoi add ~/.config/newapp/config.toml

# Edit a file
chezmoi edit ~/.config/fish/config.fish

# Apply changes
chezmoi apply
```

### Sync changes
```bash
# Pull and apply updates
chezmoi update

# Push local changes
chezmoi cd
git add .
git commit -m "Update configuration"
git push
```

## Theme

Configuration uses the **Catppuccin Mocha** color scheme across multiple applications, including the Quickshell bar and notifications.

## Notes

- Private configurations are encrypted/managed separately
- Custom environment variables are defined in `.myenv`
- Browser launches via Zen AppImage by default
- Quickshell now handles the bar and desktop notifications; disable Waybar/Dunst/Mako when using it
