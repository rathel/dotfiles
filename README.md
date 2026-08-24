# Dotfiles

Personal CachyOS/Arch Linux desktop configuration managed with
[chezmoi](https://www.chezmoi.io/).

## Home configuration

This repository manages the following parts of `$HOME`:

- **Desktop session:** Niri, Quickshell, Fuzzel, XDG portals, GTK/Qt settings,
  wallpapers, idle/lock helpers, and desktop services.
- **Shell and terminal:** Fish, Bash, Starship, `.myenv`, tmux, Foot, Alacritty,
  Ghostty, and WezTerm.
- **Editors:** Emacs with Evil, Markdown mode, Eshell, and Vim-style relative
  line numbers; Zed with age-encrypted settings.
- **Applications:** mpv, Zathura, Thunderbird, Vivaldi/Edge settings, QEMU,
  and Dropbox integration through rclone.
- **Utilities:** custom commands and launchers under `~/.local/bin`, systemd
  user units, desktop entries, icons, and the Nord - Polar Night theme.
- **Pi:** a Nord-themed Pi coding-agent configuration and extensions.

The detailed dependency inventory is in
[`DEPENDENCIES.md`](DEPENDENCIES.md).

## Fresh install

The setup was developed on CachyOS/Arch Linux, but the dependency list is
package-manager agnostic. Install the native packages that provide these
commands and applications on the target system. An AI can map these names to
the best package manager and package names for that system:

- **Bootstrap:** `git`, `chezmoi`
- **Shell:** `bash`, `fish`, `starship`
- **Desktop session:** `niri`, `quickshell` (`qs`), `fuzzel`, `swayidle`,
  `swaylock`, `wlsunset`, `xwayland-satellite`, `kdeconnect-indicator`,
  `udiskie`, and `awww` or `swaybg`
- **Terminals and CLI:** `foot`, `tmux`, `ssh`, `fd`, `sk`, `jq`, `bat`,
  `eza`, `nvim`, `curl`, and `python3`
- **Desktop services:** PipeWire/WirePlumber (`pipewire`, `wireplumber`,
  `wpctl`), NetworkManager (`nmcli`, `nm-applet`), BlueZ (`bluetoothctl`),
  XDG desktop portals, GNOME Keyring, `notify-send`, and `xdg-open`
- **Editor:** `emacs`

Install fonts, cursor/icon themes, and optional applications from
`DEPENDENCIES.md` as needed. Prefer native distribution packages; use an
alternative source only when the native package is unavailable. Verify the
result with `command -v` before applying the configuration.

Before applying the encrypted Zed settings, restore the age identity from a
secure backup and configure chezmoi:

```bash
mkdir -p ~/.config/chezmoi
install -m 600 /path/to/backup/key.txt ~/.config/chezmoi/key.txt
```

Use the following in `~/.config/chezmoi/chezmoi.toml`:

```toml
encryption = "age"

[age]
identity = "~/.config/chezmoi/key.txt"
recipient = "age1jmm8sxaqyp34pwn4ep5tyy8pgfr7zjf848m8m75w5nzlhhy4j4gqk0py72"
```

Then initialize and apply the repository:

```bash
chezmoi init <repository-url>
chezmoi diff
chezmoi apply
```

Never commit the age identity or other private credentials.
