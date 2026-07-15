# AGENTS.md

Guidance for AI/coding agents working in this chezmoi dotfiles repository.

## Repository context

- This is a personal Linux desktop dotfiles repo managed by [chezmoi](https://www.chezmoi.io/).
- Source-state files live here and are applied to `$HOME` with `chezmoi apply`.
- Primary target platform is CachyOS/Arch Linux.
- Configs mostly use the Catppuccin Mocha theme.

## Chezmoi conventions

- Chezmoi source names map to home paths:
  - `dot_config/foo` -> `~/.config/foo`
  - `dot_myenv` -> `~/.myenv`
  - `private_dot_local/bin/executable_script` -> `~/.local/bin/script` with private permissions and executable bit
  - `*.tmpl` files are chezmoi templates; keep Go-template syntax intact.
- Use `chezmoi add <target-path>` to import a file from `$HOME` into this repo.
- Use `chezmoi edit <target-path>` when editing an already-managed file from the home-path perspective.
- If editing source files directly, preserve chezmoi prefixes such as `dot_`, `private_`, and `executable_`.
- Do not commit secrets. Respect `.chezmoiignore` and `.gitignore`; keys such as `key.txt.age`, `*.pem`, `*.key`, `id_rsa*`, and `id_ed25519*` must not be added.

## Recommended workflow

Before changing files:

```bash
git status --short
chezmoi status
```

After changing files:

```bash
chezmoi diff
chezmoi apply --dry-run --verbose
```

Apply only when explicitly requested:

```bash
chezmoi apply
```

For scripts, run shell syntax checks where practical:

```bash
bash -n private_dot_local/bin/executable_*.sh
```

For templates, verify rendering with chezmoi rather than assuming plain-file syntax:

```bash
chezmoi execute-template < path/to/file.tmpl
```

## Editing guidelines

- Keep changes small, readable, and reversible.
- Prefer matching the existing style of the target config file over introducing new formatting conventions.
- Preserve executable scripts under `private_dot_local/bin/` and use POSIX shell or Bash consistently with each file's shebang.
- Be careful with window-manager configs (`dot_config/hypr/*.tmpl`, `dot_config/niri/*.tmpl`) because mistakes can break login/session startup.
- Do not rewrite vendored or third-party theme/plugin files unless specifically asked. In particular, avoid changing `dot_config/tmux/plugins/catppuccin/` without a clear reason.
- When adding a new dependency, update `DEPENDENCIES.md` if it affects setup requirements.
- When adding a new managed application or major config area, update `README.md` if user-facing documentation should mention it.

## Project map

- `README.md` — repo overview and basic chezmoi usage.
- `DEPENDENCIES.md` — packages/tools needed for this setup.
- `dot_config/` — files applied under `~/.config/`.
- `private_dot_local/bin/` — private executable helper scripts applied under `~/.local/bin/`.
- `private_dot_local/private_share/` — private local share data such as desktop entries and icons.

## Safety notes

- Never expose, print, or commit private keys, tokens, local credentials, or encrypted secret material.
- Avoid destructive commands (`rm -rf`, force resets, mass renames) unless the user explicitly asks and the target is clear.
- Do not run `chezmoi apply` or package-manager commands without explicit user approval.
