#!/usr/bin/env bash
# the actual script that makes the initramfs!
# lots of copypasta

# Long-term exposure to this code may cause loss of sanity,
# nightmares about your PC crashing of "Tried to kill init!", or any number of
# other debilitating side effects. This code is known to the State of California
# to cause cancer, birth defects, and reproductive harm.
# To not die, please do not read past this point.

# Licensed under the GPL-v3
# TODO: separate packing (tar, cpio) and compression (gzip, lzma etc) into different arguments

usage() {
    cat <<EOF
Usage: mkinitramfs.sh [-i|--input-dir=] [Input directory] [-c|--compression=] [Desired compression type] [-o|--output] [Path to image output location]

This script makes an initramfs.

Supported compression types: tar, cpio,

Input directory must be a directory with the structure and the binaries for
the initramfs. The dynamic dependencies/libraries will be calculated and copied
as needed.

Recommended: make the input directory something in /tmp.

EOF
}

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

                --input-dir=*)
                    input_dir_path="$(echo "$current_argument" | awk -F = '{print $2}')"
                ;;

                -i)
                    next_argument_type="input-dir"
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
                            export output_path="$current_argument"
                        ;;

                        compression_type)
                            export compression_type="$current_argument"
                        ;;

                        input-dir)
                            export input_dir_path="$current_argument"
                        ;;
                        *)
                            usage

                    esac
        esac

    done
}

parse_cli_args "$@"

calculate_dependencies() {
    # LMAO using eval
    parser=$(find "$input_dir_path" | while read -r line; do echo "ldd $line"; done)
    echo 'Calculating dependencies, this may take some time'
    while read -r currentline; do
        dependencies=$(echo "$currentline" | awk '{if ($1 ~ /\//) {print $1} else {print $3}}')
        export dependencies
    done < <(eval "$parser")
}

calculate_dependencies

copy_dependencies() {
    echo 'Copying dependencies, this may take some time on HDDs'
    while read -r currentline; do
        # shellcheck disable=SC2140 # we want to put a / after input_dir_path
        cp -n "$currentline" "$input_dir_path"/"$currentline"
    done < <(echo "$dependencies")
}

copy_dependencies

compress() {
    case $compression_type in

        cpio)
        echo "$input_dir_path/*" | cpio -cv > "$input_dir_path/initramfs.cpio"
        echo 'Initramfs created at'"$input_dir_path/initramfs.cpio."
        ;;

        tar)
        ls initramfs.tar && echo 'I will not overwrite initramfs.tar in current working directory. Please retry when initramfs.tar is not present in your current working directory.' && exit
        tar cvf initramfs.tar "$input_dir_path"
        ;;

    esac
}
compress
