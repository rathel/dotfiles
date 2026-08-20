function infisical-env
    if test (count $argv) -lt 2
        printf 'Usage: infisical-env <group> [group...] [--] <command> [args...]\n'
        printf 'Groups are read from Infisical when the command runs.\n'
        return 2
    end

    set -l config_dir "$HOME/.config/infisical"
    if not test -f "$config_dir/.infisical.json"
        printf 'Infisical config not found: %s/.infisical.json\n' $config_dir >&2
        return 1
    end

    if not command -q jq
        printf 'This function needs jq to read Infisical paths.\n' >&2
        return 1
    end

    set -l project_id (command jq -er '.workspaceId' "$config_dir/.infisical.json")
    set -l project_status $status
    if test $project_status -ne 0 -o (count $project_id) -ne 1
        printf 'Unable to read the Infisical project ID from %s/.infisical.json\n' $config_dir >&2
        return 1
    end

    # Query the root folders every time so new and removed paths are picked up
    # without changing this function.
    set -l folder_json (command infisical --silent secrets folders get --projectId "$project_id" --env=dev --path=/ --output=json)
    set -l folder_status $status
    if test $folder_status -ne 0
        printf 'Unable to read Infisical paths.\n' >&2
        return $folder_status
    end

    set -l available_groups (printf '%s\n' "$folder_json" | command jq -r '.[].folderName')
    set -l json_status $status
    if test $json_status -ne 0
        printf 'Unable to parse Infisical paths.\n' >&2
        return 1
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
        if test $delimiter -gt 1
            set groups $argv[1..(math $delimiter - 1)]
        end
        if test $delimiter -lt $arg_count
            set command_args $argv[(math $delimiter + 1)..-1]
        end
    else
        set -l group_count 0
        for arg in $argv
            if contains -- $arg $available_groups
                set group_count (math $group_count + 1)
            else
                break
            end
        end
        if test $group_count -gt 0
            set groups $argv[1..$group_count]
        end
        if test $group_count -lt $arg_count
            set command_args $argv[(math $group_count + 1)..-1]
        end
    end

    if test (count $groups) -eq 0
        printf 'At least one Infisical group is required.\n' >&2
        printf 'Available groups: %s\n' (string join ', ' $available_groups) >&2
        return 2
    end

    for group in $groups
        if not contains -- $group $available_groups
            printf 'Unknown Infisical group: %s\n' $group >&2
            printf 'Available groups: %s\n' (string join ', ' $available_groups) >&2
            return 2
        end
    end

    if test (count $command_args) -eq 0
        printf 'A command is required.\n' >&2
        return 2
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
