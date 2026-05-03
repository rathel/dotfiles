#!/usr/bin/env python3
import json
import os
import re
import socket
import sys
import time

# Change these to match `niri msg outputs`
PROTECTED_OUTPUT = "DP-2"       # Monitor 1, where Shadow PC lives
SAFE_OUTPUT = "DP-3"        # Monitor 2, where host windows should go

# Adjust after checking `niri msg pick-window`
SHADOW_RE = re.compile(r"(shadow|com\.shadow|tech\.shadow)", re.IGNORECASE)

# If true, refocus Shadow after moving an unwanted window away.
REFOCUS_SHADOW = True

windows = {}
workspaces = {}
seen_windows = set()
moved_windows = set()


def log(msg):
    print(f"[niri-shadow-guard] {msg}", file=sys.stderr, flush=True)


def niri_socket_path():
    path = os.environ.get("NIRI_SOCKET")
    if not path:
        raise RuntimeError("NIRI_SOCKET is not set. Start this from inside your Niri session.")
    return path


def send_request(req):
    path = niri_socket_path()

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(path)
        sock.sendall((json.dumps(req) + "\n").encode())
        sock.shutdown(socket.SHUT_WR)

        with sock.makefile("r", encoding="utf-8") as f:
            line = f.readline()
            if not line:
                return None
            return json.loads(line)


def action(action_obj):
    return send_request({"Action": action_obj})


def window_text(win):
    return " ".join(
        str(x or "") for x in [
            win.get("app_id"),
            win.get("title"),
        ]
    )


def is_shadow(win):
    # return bool(SHADOW_RE.search(window_text(win)))
    return win.get("app_id") == shadow


def workspace_output(workspace_id):
    if workspace_id is None:
        return None

    ws = workspaces.get(workspace_id)
    if not ws:
        return None

    return ws.get("output")


def window_output(win):
    return workspace_output(win.get("workspace_id"))


def shadow_on_protected_output():
    for win in windows.values():
        if is_shadow(win) and window_output(win) == PROTECTED_OUTPUT:
            return win
    return None


def move_window_to_safe_output(win):
    win_id = win.get("id")

    if win_id is None:
        return

    if win_id in moved_windows:
        return

    if is_shadow(win):
        return

    if window_output(win) != PROTECTED_OUTPUT:
        return

    shadow = shadow_on_protected_output()
    if not shadow:
        return

    log(f"Moving {win.get('app_id')} / {win.get('title')} away from {PROTECTED_OUTPUT}")

    action({
        "MoveWindowToMonitor": {
            "id": win_id,
            "output": SAFE_OUTPUT,
        }
    })

    moved_windows.add(win_id)

    if REFOCUS_SHADOW:
        shadow_id = shadow.get("id")
        if shadow_id is not None:
            action({
                "FocusWindow": {
                    "id": shadow_id,
                }
            })


def handle_event(event):
    global workspaces, windows

    if not isinstance(event, dict) or len(event) != 1:
        return

    name, payload = next(iter(event.items()))

    if name == "WorkspacesChanged":
        workspaces = {
            ws["id"]: ws
            for ws in payload.get("workspaces", [])
            if "id" in ws
        }

    elif name == "WindowsChanged":
        windows = {
            win["id"]: win
            for win in payload.get("windows", [])
            if "id" in win
        }

        for win_id in windows:
            seen_windows.add(win_id)

    elif name == "WindowOpenedOrChanged":
        win = payload.get("window")
        if not win or "id" not in win:
            return

        win_id = win["id"]
        is_new = win_id not in seen_windows

        windows[win_id] = win

        # New windows are the main thing we care about.
        # The "changed" path helps catch apps that start with a generic title/app_id.
        if is_new or window_output(win) == PROTECTED_OUTPUT:
            move_window_to_safe_output(win)

        seen_windows.add(win_id)

    elif name == "WindowClosed":
        win_id = payload.get("id")
        windows.pop(win_id, None)
        seen_windows.discard(win_id)
        moved_windows.discard(win_id)


def main():
    path = niri_socket_path()

    while True:
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                sock.connect(path)
                sock.sendall(b'"EventStream"\n')

                with sock.makefile("r", encoding="utf-8") as f:
                    log("connected to niri event stream")

                    for line in f:
                        line = line.strip()
                        if not line:
                            continue

                        try:
                            event = json.loads(line)
                        except json.JSONDecodeError:
                            continue

                        handle_event(event)

        except Exception as e:
            log(f"error: {e}; reconnecting soon")
            time.sleep(1)


if __name__ == "__main__":
    main()
