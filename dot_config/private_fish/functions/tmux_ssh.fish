function tmux_ssh
	if test "$SSH_CONNECTION"; and not test "$TMUX"; and type -q tmux
		tmux a -d ; or tmux
	end
end
