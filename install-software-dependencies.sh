#!/usr/bin/env bash
# Install software dependencies for the Linux From Scratch book
#
# Copyright _copyright_effective_year_ _copyright_holder_name_ <_copyright_holder_contact_>
# SPDX-License-Identifier: CC-BY-SA-4.0

printf \
    'Info: Configuring the defensive interpreter behaviors...\n'
set_opts=(
    # Terminate script execution when an unhandled error occurs
    -o errexit
    -o errtrace

    # Terminate script execution when an unset parameter variable is
    # referenced
    -o nounset
)
if ! set "${set_opts[@]}"; then
    printf \
        'Error: Unable to configure the defensive interpreter behaviors.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Checking the existence of the required commands...\n'
required_commands=(
    apt
    realpath
)
flag_required_command_check_failed=false
for command in "${required_commands[@]}"; do
    if ! command -v "${command}" >/dev/null; then
        flag_required_command_check_failed=true
        printf \
            'Error: This program requires the "%s" command to be available in your command search PATHs.\n' \
            "${command}" \
            1>&2
    fi
done
if test "${flag_required_command_check_failed}" == true; then
    printf \
        'Error: Required command check failed, please check your installation.\n' \
        1>&2
    exit 1
fi

if test -v BASH_SOURCE; then
    printf \
        'Info: Configuring the convenience variables...\n'
    # Convenience variables may not need to be referenced
    # shellcheck disable=SC2034
    {
        printf \
            'Info: Determining the absolute path of the program...\n'
        if ! script="$(
            realpath \
                --strip \
                "${BASH_SOURCE[0]}"
            )"; then
            printf \
                'Error: Unable to determine the absolute path of the program.\n' \
                1>&2
            exit 1
        fi
        script_dir="${script%/*}"
        script_filename="${script##*/}"
        script_name="${script_filename%%.*}"
    }
fi
# Convenience variables may not need to be referenced
# shellcheck disable=SC2034
{
    script_basecommand="${0}"
    script_args=("${@}")
}

printf \
    'Info: Setting the ERR trap...\n'
if ! trap trap_err ERR; then
    printf \
        'Error: Unable to set the ERR trap.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Checking for the running user...\n'
if test "${EUID}" != 0; then
    printf \
        'Error: This program should be run as the superuser(root).\n' \
        1>&2
    exit 1
else
    if ! running_user_username="$(whoami)"; then
        printf \
            "Error: Unable to query the running user's username.\\n" \
            1>&2
        exit 2
    fi
    printf \
        'Info: Running user is valid(%s).\n' \
        "${running_user_username}"
fi

printf \
    'Info: Installing the software dependencies...\n'
software_dependency_pkgs=(
    bash
    coreutils
    binutils
    bison
    diffutils
    findutils
    gawk
    gcc
    g++
    grep
    gzip
    m4
    make
    patch
    perl
    python3
    sed
    tar
    texinfo
    xz-utils
)
if ! apt install -y "${software_dependency_pkgs[@]}"; then
    printf \
        'Error: Unable to install the software dependency packages.\n' \
        1>&2
fi

printf \
    'Info: Operation completed without errors.\n'
