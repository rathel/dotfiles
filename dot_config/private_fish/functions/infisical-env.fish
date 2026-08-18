function infisical-env
    if test (count $argv) -lt 2
        printf 'Usage: infisical-env <group> [group...] [--] <command> [args...]\n'
        printf 'Groups: itad, steam, pushover\n'
        return 2
    end

    set -l groups
    set -l command_args
    set -l delimiter 0
    set -l arg_count (count $argv)

    for i in (seq $arg_count)
        if test "$argv[$i]" = --
            set delimiter $i
            break
        end
    end

    if test $delimiter -gt 0
        set groups $argv[1..(math $delimiter - 1)]
        set command_args $argv[(math $delimiter + 1)..-1]
    else
        set -l group_count 0
        for arg in $argv
            if contains -- $arg itad steam pushover
                set group_count (math $group_count + 1)
            else
                break
            end
        end
        set groups $argv[1..$group_count]
        set command_args $argv[(math $group_count + 1)..-1]
    end

    if test (count $groups) -eq 0
        printf 'At least one Infisical group is required.\n' >&2
        printf 'Groups: itad, steam, pushover\n' >&2
        return 2
    end

    for group in $groups
        switch $group
            case itad steam pushover
            case '*'
                printf 'Unknown Infisical group: %s\n' $group >&2
                printf 'Choose itad, steam, or pushover.\n' >&2
                return 2
        end
    end

    if test (count $command_args) -eq 0
        printf 'A command is required.\n' >&2
        return 2
    end

    set -l config_dir "$HOME/.config/infisical"
    if not test -f "$config_dir/.infisical.json"
        printf 'Infisical config not found: %s/.infisical.json\n' $config_dir >&2
        return 1
    end

    set -l path_args
    for group in $groups
        set -a path_args "--path=/$group"
    end

    command infisical run \
        --project-config-dir "$config_dir" \
        --env=dev \
        $path_args \
        -- $command_args
end
