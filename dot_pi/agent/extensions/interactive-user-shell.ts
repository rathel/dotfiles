/**
 * User-controlled interactive shell commands.
 *
 * Usage:
 *   !i <command>   Force any command to run with the real terminal attached.
 *   !sudo ...      Sudo commands are handled interactively automatically.
 *
 * This only intercepts user `!` commands. Agent bash tool calls remain
 * non-interactive, so passwords are never entered through the model.
 */

import { spawnSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function commandResult(output: string, exitCode: number) {
	return {
		result: {
			output,
			exitCode,
			cancelled: false,
			truncated: false,
		},
	};
}

export default function (pi: ExtensionAPI) {
	pi.on("user_bash", async (event, ctx) => {
		let command = event.command;
		const forced = /^i(?:\s|$)/.test(command);

		if (forced) {
			command = command.slice(1).trim();
		} else if (!/^sudo(?:\s|$)/.test(command.trim())) {
			return;
		}

		if (!command) {
			return commandResult("Usage: !i <command>", 2);
		}

		if (ctx.mode !== "tui") {
			return commandResult("Interactive commands require Pi's TUI mode.", 1);
		}

		const exitCode = await ctx.ui.custom<number>((tui, _theme, _keybindings, done) => {
			tui.stop();

			let status = 1;
			try {
				process.stdout.write("\x1b[2J\x1b[H");
				const shell = process.env.SHELL || "/bin/sh";
				const result = spawnSync(shell, ["-c", command], {
					cwd: event.cwd,
					stdio: "inherit",
					env: process.env,
				});
				status = result.status ?? 1;
			} finally {
				tui.start();
				tui.requestRender(true);
			}

			done(status);
			return { render: () => [], invalidate: () => {} };
		});

		return commandResult(
			exitCode === 0
				? "Interactive command completed successfully."
				: `Interactive command exited with code ${exitCode}.`,
			exitCode,
		);
	});
}
