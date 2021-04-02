#!/usr/bin/env bash
# the actual script that makes the initramfs!

# Licensed under the GPL-v3

read_line() {
    # The first positional argument is printf-ed, then
    #+ this function reads a line and dumps it to stdout
    #+ example usage: variable="$(read_line )"

    # we actually want to keep the escape sequences
    # shellcheck disable=SC2059
    printf "$1"
    cat /dev/stdin
}

parse_cli_args() {
    
}
