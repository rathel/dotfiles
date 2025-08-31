function chezmoi-edit
	set file (chezmoi managed | sk)
	if test -n "$file"
		chezmoi edit "$file"
	end
end
