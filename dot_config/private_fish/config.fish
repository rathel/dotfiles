if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_key_bindings fish_vi_key_bindings
    set -gx EDITOR nvim
    fish_add_path $HOME/.local/bin
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
    if test -f /home/linuxbrew/.linuxbrew/bin/brew
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
    end
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
