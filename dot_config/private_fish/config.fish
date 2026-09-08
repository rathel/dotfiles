# The persistent user service can start shells before the graphical session exports DISPLAY.
# Use the active local X server when the variable was not inherited.
if test -z "$DISPLAY"; and test -S /tmp/.X11-unix/X0
    set -gx DISPLAY :0
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_key_bindings fish_vi_key_bindings
    set -gx EDITOR nvim
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.local/state/nix/profiles/profile/bin
    if test -d "$HOME/.local/state/nix/profiles/profile/share"
        set -gx XDG_DATA_DIRS "$HOME/.local/state/nix/profiles/profile/share:"$XDG_DATA_DIRS
    end
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.npm-global/bin
    set fish_greeting
    # wallust_ssh
    # tmux_ssh
    # The upgrade script needs a terminal; skip it for non-TTY startup (for example
    # `fish -i -c ...`) so it does not print a misleading startup message.
    if isatty stdin
        /home/rathel/pg4uk-f7ecq/50_scripts/scripts/upgrade.sh
    end
    if type -q direnv
        direnv hook fish | source
    end
    if type -q zoxide
        # Fish 4.8 embeds its built-in functions, while this zoxide version
        # looks for cd.fish under $__fish_data_dir. Define the copy it needs
        # from the live cd function to avoid a missing-path warning.
        if not functions --query __zoxide_cd_internal
            functions cd | string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' | source
        end
        zoxide init fish | source
    end
    if type -q carapace
        carapace _carapace | source
    end
    if type -q starship
        starship init fish | source
    end
end

# Load the system-wide Nix environment in Fish shells.
if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# Load Guix profiles in Fish shells. Guix's generated `etc/profile` files
# contain Bash syntax, so initialize their search paths with Fish commands.
function __guix_prepend_path --argument-names variable value
    set -l current $$variable
    if not contains -- "$value" $current
        set --path --global --export $variable "$value" $current
    end
end

if test -d "$HOME/.config/guix/current"
    fish_add_path --path "$HOME/.config/guix/current/bin"
    __guix_prepend_path INFOPATH "$HOME/.config/guix/current/share/info"
    __guix_prepend_path MANPATH "$HOME/.config/guix/current/share/man"
    __guix_prepend_path GUILE_LOAD_PATH "$HOME/.config/guix/current/share/guile/site/3.0"
    __guix_prepend_path GUILE_LOAD_COMPILED_PATH "$HOME/.config/guix/current/lib/guile/3.0/site-ccache"
end

if test -f "$HOME/.guix-profile/etc/profile"
    set -gx GUIX_PROFILE "$HOME/.guix-profile"
    fish_add_path --path "$GUIX_PROFILE/bin" "$GUIX_PROFILE/sbin"
    __guix_prepend_path TREE_SITTER_GRAMMAR_PATH "$GUIX_PROFILE/lib/tree-sitter"
    __guix_prepend_path INFOPATH "$GUIX_PROFILE/share/info"
    __guix_prepend_path EMACSLOADPATH "$GUIX_PROFILE/share/emacs/site-lisp"
    __guix_prepend_path QT_PLUGIN_PATH "$GUIX_PROFILE/lib/qt6/plugins"
    __guix_prepend_path GUIX_GDK_PIXBUF_MODULE_FILES "$GUIX_PROFILE/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    __guix_prepend_path XDG_DATA_DIRS "$GUIX_PROFILE/share"
    __guix_prepend_path GIO_EXTRA_MODULES "$GUIX_PROFILE/lib/gio/modules"
    __guix_prepend_path XCURSOR_PATH "$GUIX_PROFILE/share/icons"
    __guix_prepend_path VDPAU_DRIVER_PATH "$GUIX_PROFILE/lib/vdpau"
    __guix_prepend_path GUIX_GTK3_PATH "$GUIX_PROFILE/lib/gtk-3.0"
    __guix_prepend_path GUIX_LOCPATH "$GUIX_PROFILE/lib/locale"
    __guix_prepend_path MANPATH "$GUIX_PROFILE/share/man"
    __guix_prepend_path ZATHURA_PLUGINS_PATH "$GUIX_PROFILE/lib/zathura"
end

functions --erase __guix_prepend_path

# Keep Homebrew ahead of package-manager profiles in every Fish invocation, so
# scripts and interactive shells select the current chezmoi release.
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/rathel/.lmstudio/bin
# End of LM Studio CLI section

# Added by Antigravity CLI installer
set -gx PATH "/home/rathel/.local/bin" $PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/rathel/google-cloud-sdk/path.fish.inc' ]; . '/home/rathel/google-cloud-sdk/path.fish.inc'; end

# opencode
fish_add_path /home/rathel/.opencode/bin

# OpenClaw Completion
test -f "/home/rathel/.openclaw/completions/openclaw.fish"; and source "/home/rathel/.openclaw/completions/openclaw.fish"

# Pi
fish_add_path "/home/rathel/.local/share/pi-node/node-v22.23.2-linux-x64/bin"

# Aardwolf MUD
alias aardwolf='telnet aardmud.org 4000'

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
