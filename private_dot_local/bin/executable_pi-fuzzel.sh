#!/usr/bin/env bash

set -euo pipefail

if ! command -v fuzzel >/dev/null 2>&1; then
    printf 'pi-fuzzel: fuzzel is required\n' >&2
    exit 1
fi

pi_command=$(command -v pi 2>/dev/null || true)
if [[ -z "$pi_command" ]]; then
    printf 'pi-fuzzel: pi is required\n' >&2
    exit 1
fi

if ! prompt=$(fuzzel --dmenu --prompt-only='pi: '); then
    # Escape cancels the fuzzel prompt.
    exit 0
fi

[[ -n "$prompt" ]] || exit 0

# Keep output in the invoking terminal when one is available.  When launched
# from a compositor keybinding, open a terminal so the response is visible.
if [[ -t 1 ]]; then
    exec "$pi_command" -p "$prompt"
fi

terminal=${PI_TERMINAL:-kitty}
if ! command -v "$terminal" >/dev/null 2>&1; then
    printf 'pi-fuzzel: terminal not found: %s\n' "$terminal" >&2
    exit 1
fi

case "$(basename "$terminal")" in
    kitty | foot | alacritty)
        exec "$terminal" --hold "$pi_command" -p "$prompt"
        ;;
    *)
        exec "$terminal" -e "$pi_command" -p "$prompt"
        ;;
esac
