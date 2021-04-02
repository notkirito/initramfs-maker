#!/usr/bin/env bash
# the actual script that makes the initramfs!
# lots of copypasta

# Long-term exposure to this code may cause loss of sanity,
# nightmares about your PC crashing of "Tried to kill init!", or any number of
# other debilitating side effects. This code is known to the State of California
# to cause cancer, birth defects, and reproductive harm.
# To not die, please do not read past this point.

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

    # new array called cli_arguments
    export cli_arguments=("$@")

    for i in "${!cli_arguments[@]}"; do

        current_argument=${cli_arguments[$i]}

            case ${cli_arguments[$i]} in

                    --compression=*)
                        compression_type=$(echo "$current_argument" | awk -F = '{print $2}')
                        export compression_type
                        ;;

                    --output=*)
                        output_path=$(echo "$current_argument" | awk -F = '{print $2}')
                        export output_path
                        ;;

                    -o*)
                        next_argument_type="output_path"
                        ;;
                    -c*)
                        next_argument_type="compression_type"
                        ;;
                    *)
                        # another case statement, INSIDE THE FIRST ONE, i said NOT FOR PROD
                        case "$next_argument_type" in

                            output_path)
                                output_path="$current_argument"
                            ;;

                            compression_type)
                                compression_type="$current_argument"
                            ;;



                esac
        esac

    done
}
