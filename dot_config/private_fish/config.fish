set -x EDITOR nvim
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'" 
set -x PATH $PATH ~/.local/bin

neofetch

alias vim=nvim

starship init fish | source
