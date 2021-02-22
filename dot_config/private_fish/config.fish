set -x EDITOR nvim
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'" 

starship init fish | source
