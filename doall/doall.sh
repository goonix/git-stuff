#!/usr/bin/env bash

target_file=".doall.conf"

# Color aliases
NO_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

echo_red() {
    echo -e "${RED}${*}${NO_COLOR}"
}

echo_green() {
    echo -e "${IGreen}${*}${NO_COLOR}"
}

echo_yellow() {
    echo -e "${YELLOW}${*}${NO_COLOR}"
}


# read value from config file
# ${1} - config file
# ${2} - key
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2-;
}

# get value from misc. config
# ${1} - key
config_get() {
    val="$(config_read_file "${conf_file}" "${1}")";
    if [ "${val}" = "__UNDEFINED__" ]; then
        val="$(config_read_file "${conf_file}.defaults" "${1}")";
    fi
    printf -- "%s" "${val}";
}

get_help() {
   cat << HEREDOC
   $0 [ -c ] [ -h ] [ command_to_perform ]
   -c print the repos/directories upon which to perform "command_to_perform" and exit
      A similar behavior if no arguments are passed to $0
   -h print this help and exit
   command_to_perform
       Without command line flags, command_to_perform will be executed on each configured repo/directory
HEREDOC
}

show_config() {
   cat << HEREDOC
   Repos definined in config: ${conf_file}
      ${repos}
HEREDOC
}


# Check if the file exists in the current directory
if [ -f "$target_file" ]; then
    echo "File found in current directory: $PWD/$target_file"
    parent_dir="${PWD}"
    conf_file="${PWD}/${target_file}"
else
    # Search for the file in parent directories
    current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        parent_dir="$(dirname "$current_dir")"
        if [ -f "$parent_dir/$target_file" ]; then
            echo "File found in parent directory: $parent_dir/$target_file"
            conf_file="${parent_dir}/${target_file}"
            break
        fi
        current_dir="$parent_dir"
    done

    # If the file was not found
    if [ "$current_dir" == "/" ]; then
        echo "File not found in any parent directory."
    fi
fi

echo "Using config from ${conf_file}"
repos="$(config_get repos)";

orig_dir="${CWD}"
# if [ "${@}" = ]

while getopts ":hc" option; do
   case $option in
      h) # display Help
         get_help
         exit;;
      c) # print the repos/directories upon which to perform "command_to_perform" and exit
         show_config
         exit;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
      :) # Missing option
         echo "Error: Missing option argument for -$OPTARG"
         exit;;
   esac
done
for repo in $repos; do
    echo_green "==========================================="
    echo_green "$repo"
    echo_green "--------------------"
    cd "${parent_dir}/${repo}" && "${@}"
done
cd "${orig_dir}" || return
