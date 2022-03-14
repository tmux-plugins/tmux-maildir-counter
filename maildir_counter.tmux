#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{maildir_counter_N}"

# Possible configurations.
# MUST contain the list of folders separated by |
maildir_counters='@maildir_counters'
maildir_unread_counter='@maildir_unread_counter'

interpolate() {
    local -r status="$1"
    local -r counter="${place_holder/N/$2}"
    local -r count_files="#(ls -1 $3 | wc -l | xargs)"
    local -r count_files_cur="#(ls -1 $3/cur | grep -v ':2,.*S' | wc -l | xargs)"
    local -r count_files_new="#(ls -1 $3/new | wc -l | xargs)"

    local -r enable_unread_counter=$4

    local count_files_output=$count_files
    if [ "$enable_unread_counter" == 'yes' ]; then
        count_files_output=$count_files_cur+$count_files_new
    fi
    local -r status_value=$(tmux show-option -gqv "$status")
    tmux set-option -gq "$status" "${status_value//$counter/$count_files_output}"
}

main() {
    IFS=\|
    local i=1
    local toggle_unread_counter=$(tmux show-option -gqv "$maildir_unread_counter")
    local interpolated_options="$(get_tmux_option "@plugin_interpolated_options" "status-right status-left")"
    for maildir in $(tmux show-option -gqv "$maildir_counters"); do
        for interpolated_option in $interpolated_options
        do
            interpolate $interpolated_option "$i" "$maildir" "$toggle_unread_counter"
        done
        i=$((i+1))
    done
}

main
