Based on my analysis of the repository, here's a comprehensive dependency list for setting up this dotfiles configuration on CachyOS (Arch-based Linux). I've categorized the dependencies and included notes on where they're referenced or used.

## Core System Packages
These are the main applications and tools configured in the dotfiles:

- **Terminal Emulators**: `alacritty`, `foot`, `ghostty`, `wezterm`
- **Shell & Prompt**: `fish`, `starship`
- **Terminal Multiplexer**: `tmux`
- **Window Managers/Compositors**: `niri`
- **Desktop Shell**: `quickshell`
- **Codex Usage Meter**: OpenAI Codex CLI (`@openai/codex`), logged in with a ChatGPT subscription
- **Pi web search**: Brave Search extension (`@firstpick/pi-extension-brave-search`); configure its API key in Pi with `/brave-search-setup`
- **Status Bar**: `waybar` (legacy)
- **Notification Daemons**: `dunst`, `mako` (legacy)
- **Application Launcher**: `fuzzel`
- **File Utilities**: `eza` (modern ls), `fd` (fd-find), `skim` (sk fuzzy finder), `curl` (weather widget), `xdg-utils` (provides `xdg-open`)
- **Media**: `mpv`
- **Text Editors**: `emacs`, `neovim`, `zed` (CLI: `zeditor`)
- **Directory Navigation**: `zoxide`, `direnv`
- **Wallpaper Tools**: `swww`, `wallust`, `awww`
- **PDF Viewer**: `zathura`
- **Virtualization**: `qemu-system-x86_64`, `qemu-img`
- **Audio Control**: `wireplumber` (for wpctl)
- **Notifications**: `libnotify` (provides notify-send)
- **Email Client**: `thunderbird`
- **Thunderbird MCP**: `TKasperczyk/thunderbird-mcp` v0.7.4 (local bridge plus Thunderbird extension)
- **Python**: `python3`
- **Package Managers**: `pacman`, `paru` (AUR helper)
- **Dotfile Manager**: `chezmoi` with built-in age encryption support

## Emacs packages
- **Evil**: installed automatically from GNU ELPA/MELPA by `~/.emacs.d/init.el`

## Fonts
- **Nerd Fonts**: `ttf-iosevka-nerd` (or similar Iosevka variants with Nerd Font patches)
- These are required for icons in terminals, tmux, and other applications

## Themes & Plugins
- **Nord - Polar Night**: The canonical Nord palette is embedded directly in the managed configs, so no external theme package is required.
- Zellij and Herdr use their built-in Nord themes; tmux uses native styling and requires no theme plugin.

## Additional Dependencies from Scripts
Scripts in `private_dot_local/bin/` require these tools:
- Core utilities: `awk`, `sha256sum`, `stat`, `findmnt`, `xargs`, `shuf`, `pgrep`, `pkill`, `date`
- These are typically part of base system packages like `coreutils`, `util-linux`, `procps-ng`
- Microsoft Edge installer: `curl`, `gzip`, `binutils` (for `ar`), `tar`, and `sha256sum`

## Optional/Conditional Dependencies
- **Linuxbrew**: For additional package management (checked in fish config)
- **Flatpak**: For flatpak application updates (in upgrade script)
- **Distrobox**: For container management (in upgrade script)

## Installation Notes
1. Most packages can be installed via `pacman` or `paru` on CachyOS
2. Fonts should be installed from the AUR or official repositories
3. Nord colors are configured locally; no separate theme installation is needed
4. Restore the chezmoi age identity to `~/.config/chezmoi/key.txt` before applying encrypted files

This list covers all dependencies identified from configuration files, scripts, and documentation in the repository. Some dependencies may already be installed on a base CachyOS system.
