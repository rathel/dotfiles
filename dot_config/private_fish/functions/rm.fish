function rm
    set -l args

    for arg in $argv
        # Strip the force flag from short-option bundles (for example, -vfr -> -vr).
        if string match --quiet --regex '^-[^-].*' -- $arg
            set arg (string replace --all 'f' '' -- $arg)
            if test "$arg" != '-'
                set args $args $arg
            end
        else
            set args $args $arg
        end
    end

    command rm $args
end
