#!/usr/bin/env bash

set -eo pipefail

source ../lib/util/git.sh
source ../lib/dotfiles.sh

# this must be after sourcing dotfiles
source ../state/env.sh
source ../lib/util/helpers.sh
source ../lib/util/ssh.sh
source ../lib/code.sh
source ../lib/mamba.sh
source ../lib/mamba-env.sh

main() {

    print_double_line
    echo 'Installing dotfiles'
    dotfiles_install
    # shellcheck disable=SC1090
    . ~/.bashrc || true

    print_double_line
    echo 'Installing VSCode CLI'
    code_install
    print_double_line
    echo "Installing mamba to ${MAMBA_ROOT_PREFIX}"
    mamba_install
    # shellcheck disable=SC1090
    . ~/.bashrc || true

    print_double_line
    echo 'Installing system environment via mamba'
    mamba_env_install
    print_double_line

    print_double_line
    echo 'Generating SSH key and login to GitHub'
    ssh_keygen_and_login
}

main
