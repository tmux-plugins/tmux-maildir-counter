#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{maildir_counter_N}"

# Possible configurations.
# MUST contain the list of folders separated by |
maildir_counters='@maildir_counters'

interpolate() {
    local -r status="$1"
    local -r counter="${place_holder/N/$2}"
    local -r count_files="#(ls -1 $3 | wc -l | xargs)"
    local -r status_value=$(tmux show-option -gqv "$status")
    tmux set-option -gq "$status" "${status_value/$counter/$count_files}"
}

main() {
    IFS=\|
    local i=1
    for maildir in $(tmux show-option -gqv "$maildir_counters"); do
        interpolate "status-left" "$i" "$maildir"
        interpolate "status-right" "$i" "$maildir"
        i=$((i+1))
    done
}

main
