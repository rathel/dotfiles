function tmux_ssh
	if test "$SSH_CONNECTION"
		if not test "$TMUX"
			tmux a -d ; or tmux
		end
	end
end
