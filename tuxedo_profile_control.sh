#!/bin/bash

# Configuration
BUS_ARGS="--system --dest com.tuxedocomputers.tccd --object-path /com/tuxedocomputers/tccd --method com.tuxedocomputers.tccd"

# Helper to call gdbus and clean the output string
call_tcc() {
    gdbus call $BUS_ARGS."$1" | sed "s/^('//;s/',)$//"
}

list_profiles() {
    local json=$(call_tcc "GetProfilesJSON")
    echo "ID | Name"
    echo "---|---"
    echo "$json" | jq -r '.[] | "\(.id) | \(.name)"'
}

set_profile() {
    local target_id="$1"
    local all_json=$(call_tcc "GetProfilesJSON")
    local target_name=$(echo "$all_json" | jq -r --arg id "$target_id" '.[] | select(.id == $id) | .name')

    echo "Switching to profile ID: $target_id..."
    # TCCD expects the ID passed as a string argument to SetProfile
    gdbus call $BUS_ARGS.SetTempProfileById "$target_id" > /dev/null
    notify-send "Tuxedo Control Center" "Switched to profile: $target_name"
}

next_profile() {
    local active_json=$(call_tcc "GetActiveProfileJSON")
    local current_id=$(echo "$active_json" | jq -r '.id')
    local all_json=$(call_tcc "GetProfilesJSON")

    mapfile -t ids < <(echo "$all_json" | jq -r '.[].id')

    # Find the index of the current ID
    for i in "${!ids[@]}"; do
        if [[ "${ids[$i]}" == "$current_id" ]]; then
            next_idx=$(( (i + 1) % ${#ids[@]} ))
            set_profile "${ids[$next_idx]}"
            return
        fi
    done
}

# Logic for flags
case "$1" in
    --list|-l)
        list_profiles
        ;;
    --current|-c)
        call_tcc "GetActiveProfileJSON" | jq -r '"Current Profile: \(.name) (ID: \(.id))"'
        ;;
    --set|-s)
        if [[ -z "$2" ]]; then
            echo "Error: Please provide a profile ID."
            exit 1
        fi
        set_profile "$2"
        ;;
    --next|-n)
        next_profile
        ;;
    *)
        echo "Usage: $0 {--list|--next|--set ID}"
        echo "  --list -l    : Show all available profiles"
        echo "  --current -c : Show the currently active profile"
        echo "  --next -n    : Cycle to the next profile"
        echo "  --set ID -s ID  : Switch to a specific profile ID"
        ;;
esac
