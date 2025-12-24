if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_key_bindings fish_vi_key_bindings
    set -gx EDITOR nvim
    set -gx PATH $HOME/.local/bin $HOME/.npm-global/bin
    set fish_greeting
    # wallust_ssh
    # tmux_ssh
    /home/rathel/pg4uk-f7ecq/Scripts/upgrade.sh
    direnv hook fish | source
    zoxide init fish | source
    starship init fish | source
end
