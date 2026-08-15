"""qutebrowser configuration."""

import shlex


# Keep settings changed through qutebrowser's UI (autoconfig.yml).
config.load_autoconfig()

# qutebrowser ships the qute-bitwarden userscript. Use fuzzel instead of its
# default rofi invocation so it matches the rest of this desktop.
_BITWARDEN_MENU = "fuzzel --dmenu --prompt='Bitwarden: '"
_BITWARDEN_PASSWORD_PROMPT = (
    "fuzzel --dmenu --password "
    "--prompt-only='Bitwarden master password: '"
)
_BITWARDEN_AUTO_LOCK = 900


def _bitwarden_command(*options):
    """Build a qutebrowser command for the bundled Bitwarden userscript."""
    return " ".join(
        [
            "spawn",
            "--userscript",
            "qute-bitwarden",
            "--dmenu-invocation",
            shlex.quote(_BITWARDEN_MENU),
            "--password-prompt-invocation",
            shlex.quote(_BITWARDEN_PASSWORD_PROMPT),
            "--auto-lock",
            str(_BITWARDEN_AUTO_LOCK),
            *options,
        ]
    )


# Use these from normal mode (press Escape first if a form is focused).
config.bind(",bw", _bitwarden_command())
config.bind(",bwu", _bitwarden_command("--username-only"))
config.bind(",bwp", _bitwarden_command("--password-only"))
config.bind(",bwt", _bitwarden_command("--totp-only"))
