# Dependencies

This is the dependency reference for the home configuration. It was developed on CachyOS/Arch Linux, but it does not prescribe a package manager. The names below are commands, services, or applications; map them to the native package names for the target system.

## Fresh-install baseline

Install native packages that provide these commands and applications. An AI
can use this list to select the best package manager and package names for the
target system:

- **Bootstrap:** `git`, `chezmoi`
- **Shell:** `bash`, `fish`, `starship`
- **Desktop session:** `niri`, `quickshell` (`qs`), `tofi`, `fuzzel`, `swayidle`,
  `swaylock`, `wlsunset`, `xwayland-satellite`, `kdeconnect-indicator`,
  `udiskie`, and `awww` or `swaybg`
- **Terminals and CLI:** `foot`, `tmux`, `ssh`, `fd`, `sk`, `jq`, `bat`,
  `eza`, `nvim`, `curl`, and `python3`
- **Desktop services:** PipeWire/WirePlumber (`pipewire`, `wireplumber`,
  `wpctl`), NetworkManager (`nmcli`, `nm-applet`), BlueZ (`bluetoothctl`),
  XDG desktop portals (`xdg-desktop-portal`, `xdg-desktop-portal-gtk`, and
  `xdg-desktop-portal-wlr` plus `slurp` for Niri/Wayland), GNOME Keyring,
  `notify-send`, and `xdg-open`
- **Editor:** `emacs`

Install fonts, cursor/icon themes, and optional applications from the sections
below as needed. Prefer native distribution packages; use an alternative
source only when a native package is unavailable. Verify installed commands
with `command -v` before applying the configuration.

## Core setup

These are the dependencies for the normal shell, Niri, Quickshell, and helper-script setup:

- **Dotfiles and source control**: `chezmoi`, `git`.
  Chezmoi has built-in age support; restore the age identity at
  `~/.config/chezmoi/key.txt` before applying encrypted files. A separate `age`
  executable is not required by default.
- **Shell and prompt**: `fish`, `bash`, `starship`.
- **Niri desktop**: `niri`, `quickshell` (the session starts it as `qs`),
  `tofi`, and `fuzzel`.
- **Interactive CLI helpers**: `skim` (`sk`), `fd`, `jq`, `bat`, `eza`, and
  `neovim` (`nvim`).
- **Terminal workflow**: `tmux` and an OpenSSH-compatible `ssh` client.
- **General tools**: `curl` and `python3`.
- **Optional Fish enhancements**: `zoxide`, `direnv`, and `carapace`; the Fish
  config initializes them only when they are present.
- **Fonts and cursors**: Iosevka Nerd Font variants (`Iosevka Nerd Font` and
  `IosevkaTerm Nerd Font`) and the `breeze_cursors` cursor theme.
- **Quickshell icons**: the `Surfn-Arc` icon theme is selected by the shell.

## Configured terminal emulators

The repository configures several terminals, but they are alternatives rather
than all being required. The current keybindings and scripts use `foot` most
often; `alacritty` is the editor helper's preferred terminal. `ghostty` and
`wezterm` are configured fallbacks/integrations.

- `alacritty`
- `foot`
- `ghostty`
- `wezterm`

## Niri and Quickshell session services

The Niri template starts these programs directly:

- `swayidle` and `swaylock` on hosts other than `archlinux-beelink`.
- `wlsunset`, `xwayland-satellite`, `kdeconnect-indicator`, `nm-applet`, and
  `udiskie` on every host.
- A locally built `niri-shadow-guard` binary at
  `~/git/niri-shadow-guard-gui-src/target/release/niri-shadow-guard` on hosts
  other than `archlinux-beelink`.
- `awww` is the preferred wallpaper backend; `swaybg` is the fallback.

The Quickshell bar calls these tools for status data:

- `wpctl` from WirePlumber/PipeWire.
- `brightnessctl`.
- `nmcli` from NetworkManager and `bluetoothctl` from BlueZ.
- `curl` for the weather widget.

The Quickshell notification server replaces the legacy notification daemons.
`libnotify` (`notify-send`) is still used by several helper scripts.

The portal configuration expects `xdg-desktop-portal`, the GTK backend, and
`xdg-desktop-portal-wlr` plus `slurp` for Niri/Wayland screenshots. It also
uses `gnome-keyring` for the configured Secret portal. The GNOME portal backend
is only needed when using a GNOME session.

## Managed applications and feature groups

Install these only when using the corresponding configuration or helper:

- **Editors**: `emacs`, `evil`, and `markdown-mode` (Evil and Markdown mode
  are installed automatically from NonGNU ELPA by `~/.emacs.d/init.el`;
  Eshell is built into Emacs), plus `zed`/`zeditor`.
- **Terminal multiplexer integration**: `herdr`. It is required by the SSH host
  picker for non-special hosts.
- **Media and documents**: `mpv` and `zathura`.
- **Email**: Thunderbird, either the portable copy under
  `~/Applications/Communication/thunderbird` or a `thunderbird`/`thunderbird-bin`
  executable in `PATH`.
- **Dropbox mount**: `rclone` and `fusermount3` for
  `dot_config/systemd/user/rclone-dropbox.service`; configure the `dropbox:`
  remote separately.
- **Virtual machines**: `qemu-system-x86_64` and `qemu-img`.
- **System upgrades**: `topgrade` for `dot_config/topgrade.toml`.

Browser launchers can use any of the following, depending on the selected
entry: Firefox, Zen (the default in `.myenv`), Vivaldi, Brave, Chromium/Chrome,
or Microsoft Edge. The Edge installer extracts the official package into
`~/Applications/Utilities/microsoft-edge` without root privileges.

## Helper-script dependencies

The following are the non-obvious dependencies of the scripts under
`private_dot_local/bin/`:

| Feature | Additional dependencies |
| --- | --- |
| `niri-app`, window switching, screenshots | `niri`, `fuzzel`, `jq`, `notify-send` for error notifications |
| Desktop launcher cache | `fd`, `sk`, `awk`, `findmnt`, `sha256sum`, `stat`, `xargs` |
| Chezmoi editors | `chezmoi`, `sk`, `bat`, `git`, an editor, and a terminal; `notify-send` is used for errors |
| PDF launcher | `fd`, `sk`, `zathura`, `notify-send` |
| Streaming-service launcher | `fuzzel`, `xdg-open` (`xdg-utils`), and optionally `notify-send` |
| Wallpaper launcher | `awww` **or** `swaybg` |
| Volume notifications | `wpctl`, `pactl`, `notify-send`, `awk`, `grep`, and `stdbuf` |
| Stream recording helper | `yt-dlp` and `awk` |
| Tailscale SSH helper | `tailscale`, `hostnamectl`, `ssh`, a terminal, and `tmux`; `wezterm` enables its tab/pane integration |
| SSH host picker | `tofi`, a terminal (defaults to `foot`), `ssh`, `python3`, `herdr`, and `tmux` for the special host |
| Microsoft Edge installer | `curl`, `gzip`, `awk`, `ar` (`binutils`), `tar`, and `sha256sum` |
| Desktop-entry creator | `desktop-file-validate` and `update-desktop-database` are optional; `chezmoi` is used when available |
| Thunderbird backup | `pgrep`, `pkill`, `tar`, and `xz` |
| QEMU launcher | `qemu-system-x86_64` and `qemu-img` |
| `infisical-env` Fish function | `infisical`, `jq`, and a local Infisical project configuration |
| Pi launcher and Codex meter | `pi`, a terminal, Python, and the OpenAI Codex CLI |

Most remaining commands are provided by the target system's base utilities:
filesystem tools, `awk`, `grep`, `sed`, process tools, `util-linux`, `systemd`,
`tar`, `xz`, and `gzip`. They normally do not need separate installation.
`jq` and `skim` (`sk`) are the notable extra command-line tools used by
multiple helpers.

## Optional external integrations

These are referenced conditionally or through local paths and are not needed
to apply the core dotfiles:

- Pi's Brave search extension: `@firstpick/pi-extension-brave-search`,
  configured with `/brave-search-setup`; install it through the extension's
  supported package mechanism.
- The OpenClaw completion file, OpenCode, LM Studio CLI, Google Cloud SDK, and
  Linuxbrew are sourced only when their local installations exist.
- `ollama-chat` uses only Python's standard library and connects to a remote
  Ollama service; a local Ollama installation is not required.
- Obsidian, Discord, Beeper, Steam's external Fuzzel launcher, Shadow PC, and
  local AppImages are host-specific applications referenced by the Niri binds.
- The `upgrade.sh` and `waybar_timer` helpers referenced by the Fish/Waybar
  setup live outside this repository.

## Legacy and deliberately omitted dependencies

- Quickshell now provides the bar and notifications. `waybar`, `dunst`, and
  `mako` remain as legacy/fallback configurations; install them only if those
  paths are used. The Waybar fallback also needs the external `waybar_timer`
  helper.
- `swww` and `wallust` are not used by the active configuration. The wallpaper
  script uses `awww` with a `swaybg` fallback.
- No specific package manager is a runtime dependency of this repository.
  Flatpak, Distrobox, and Linuxbrew are optional environment choices.
- Nord colors are embedded in the managed configurations, and Herdr plus
  native tmux styling do not require an external theme package.
