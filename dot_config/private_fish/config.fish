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
    /home/rathel/pg4uk-f7ecq/50_scripts/scripts/upgrade.sh
    direnv hook fish | source
    zoxide init fish | source
    starship init fish | source
    if test -f /home/linuxbrew/.linuxbrew/bin/brew
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
    end
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/rathel/.lmstudio/bin
# End of LM Studio CLI section

# Added by Antigravity CLI installer
set -gx PATH "/home/rathel/.local/bin" $PATH
