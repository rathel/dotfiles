# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains configuration files for my Linux development environment on CachyOS.

## Managed Applications

### Terminal & Shell
- **alacritty** - Terminal emulator
- **foot** - Wayland terminal
- **ghostty** - Terminal emulator
- **fish** - Shell configuration (private)
- **starship** - Shell prompt
- **tmux** - Terminal multiplexer with Catppuccin theme

### Wayland & Desktop
- **hypr** - Hyprland compositor
- **niri** - Niri compositor
- **waybar** - Status bar
- **dunst** - Notification daemon
- **mako** - Notification daemon
- **fuzzel** - Application launcher

### Utilities
- **eza** - Modern ls replacement with custom theme
- **mpv** - Media player (private)

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

Configuration uses the **Catppuccin Mocha** color scheme across multiple applications.

## Notes

- Private configurations are encrypted/managed separately
- Custom environment variables are defined in `.myenv`
- Browser launches via Zen AppImage by default
