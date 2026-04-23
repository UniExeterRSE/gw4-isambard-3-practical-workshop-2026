#!/usr/bin/env bash

set -eo pipefail

# git 2.3.0 or later is required
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

github_clone_git() {
    user="${1}"
    repo="${2}"
    git clone "git@github.com:${user}/${repo}.git"
}

github_clone_https() {
    user="${1}"
    repo="${2}"
    git clone "https://github.com/${user}/${repo}.git"
}

github_download_file_to() {
    user="${1}"
    repo="${2}"
    branch="${3}"
    file="${4}"
    dest="${5}"
    mkdir -p "${dest%/*}"
    curl -fSL "https://raw.githubusercontent.com/${user}/${repo}/refs/heads/${branch}/${file}" -o "${dest}"
}
dotfiles_install() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_dir="${script_dir}/../dotfiles"
    local target_dir="${HOME}"
    local src dest

    for src in "${dotfiles_dir}"/.*; do
        [[ "$(basename "${src}")" == "." ]] && continue
        [[ "$(basename "${src}")" == ".." ]] && continue

        dest="${target_dir}/$(basename "${src}")"

        if [[ -L ${dest} ]]; then
            echo "already a symlink, skipping: ${dest}"
            continue
        fi

        if [[ -e ${dest} ]]; then
            echo "backing up existing file: ${dest} -> ${dest}.bak"
            mv "${dest}" "${dest}.bak"
        fi

        ln -s "${src}" "${dest}"
        echo "linked: ${dest} -> ${src}"
    done
}

dotfiles_uninstall() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_dir="${script_dir}/../dotfiles"
    local target_dir="${HOME}"
    local src dest

    for src in "${dotfiles_dir}"/.*; do
        [[ "$(basename "${src}")" == "." ]] && continue
        [[ "$(basename "${src}")" == ".." ]] && continue

        dest="${target_dir}/$(basename "${src}")"

        if [[ -L ${dest} ]]; then
            rm "${dest}"
            echo "removed symlink: ${dest}"
        fi
    done
}

# this must be after sourcing dotfiles
__OPT_ROOT="${__OPT_ROOT:-"${HOME}/.local"}"
MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-"${HOME}/.miniforge3"}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
print_double_line() {
    echo '================================================================================'
}

print_line() {
    echo '--------------------------------------------------------------------------------'
}
BSOS_SSH_COMMENT="${USER}@${HOSTNAME}"

ssh_keygen_and_login() {
    # determine ssh algorithm to use
    # shellcheck disable=SC2312
    if ssh -Q key | grep -q "ssh-ed25519"; then
        SSH_ALGO=ed25519
    elif ssh -Q key | grep -q "ssh-rsa"; then
        SSH_ALGO=rsa
    else
        echo "No supported ssh algorithm found, abort..."
        return
    fi

    if [[ -f "${HOME}/.ssh/id_${SSH_ALGO}.pub" ]]; then
        echo "SSH key already exists, assuming ssh-agent is setup to pull from GitHub and skip generating ssh key."
    else
        echo "Generating ssh key for ${BSOS_SSH_COMMENT}"
        mkdir -p "${HOME}/.ssh"
        ssh-keygen -t "${SSH_ALGO}" -C "${BSOS_SSH_COMMENT}" -f "${HOME}/.ssh/id_${SSH_ALGO}"
        # shellcheck disable=SC1090,SC2312
        . <(ssh-agent -s)
        ssh-add "${HOME}/.ssh/id_${SSH_ALGO}"

        # authenticate with GitHub
        gh auth login --git-protocol ssh --web
    fi
}
BINDIR="${__OPT_ROOT}/bin"

# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"

code_install() {
    case "${__OSTYPE}-${__ARCH}" in
        "Linux-x86_64")
            url="https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64"
            ;;
        "Linux-armv7l")
            url="https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-armhf"
            ;;
        "Linux-aarch64")
            url="https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64"
            ;;
        "Darwin-x86_64")
            url="https://code.visualstudio.com/sha/download?build=stable&os=cli-darwin-x64"
            ;;
        "Darwin-arm64")
            url="https://code.visualstudio.com/sha/download?build=stable&os=cli-darwin-arm64"
            ;;
        *)
            echo "Unsupported OS or architecture"
            exit 1
            ;;
    esac

    case "${__OSTYPE}" in
        Darwin)
            if command -v curl > /dev/null; then
                curl -L "${url}" -o vscode_cli.zip
            elif command -v wget > /dev/null; then
                wget "${url}" -O vscode_cli.zip
            fi
            unzip vscode_cli.zip
            rm vscode_cli.zip
            ;;
        Linux)
            if command -v curl > /dev/null; then
                # shellcheck disable=SC2312
                curl -fL "${url}" | tar -xz
            elif command -v wget > /dev/null; then
                # shellcheck disable=SC2312
                wget -O - "${url}" | tar -xz
            fi
            ;;
        *) ;;
    esac

    mkdir -p "${BINDIR}"
    mv code "${BINDIR}"
}

code_uninstall() {
    rm -rf "${BINDIR}/code"
}
# https://unix.stackexchange.com/a/84980/192799
DOWNLOADDIR="$(mktemp -d 2> /dev/null || mktemp -d -t 'miniforge3')"

# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"

mamba_install() {
    case "${__OSTYPE}-${__ARCH}" in
        Darwin-arm64) ;;
        Darwin-x86_64) ;;
        Linux-x86_64) ;;
        Linux-aarch64) ;;
        Linux-ppc64le) ;;
        *) exit 1 ;;
    esac
    # https://github.com/conda-forge/miniforge
    downloadUrl="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-${__OSTYPE}-${__ARCH}.sh"

    print_double_line
    echo Downloading to temp dir "${DOWNLOADDIR}"
    cd "${DOWNLOADDIR}" || exit 1
    curl -fSL "${downloadUrl}" -o Miniforge3.sh
    chmod +x Miniforge3.sh

    print_double_line
    if [[ -f "${MAMBA_ROOT_PREFIX}/etc/profile.d/conda.sh" ]]; then
        echo Updating mamba...
        ./Miniforge3.sh -ubsp "${MAMBA_ROOT_PREFIX}"
    else
        echo Installing mamba...
        ./Miniforge3.sh -fbsp "${MAMBA_ROOT_PREFIX}"
    fi

    print_line
    echo Removing temp dir "${DOWNLOADDIR}"
    cd - || exit 1
    rm -rf "${DOWNLOADDIR}"
}

mamba_uninstall() {
    rm -rf "${MAMBA_ROOT_PREFIX}"
}
NAME="${NAME:-system}"

PREFIX="${__OPT_ROOT}/${NAME}"

# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"

get_conda_env_file() {
    case "${__OSTYPE}-${__ARCH}" in
        Darwin-arm64) CONDA_UNAME=osx-arm64 ;;
        Darwin-x86_64) CONDA_UNAME=osx-64 ;;
        Linux-x86_64) CONDA_UNAME=linux-64 ;;
        Linux-aarch64) CONDA_UNAME=linux-aarch64 ;;
        Linux-ppc64le) CONDA_UNAME=linux-ppc64le ;;
        *) exit 1 ;;
    esac
    local filename
    filename="${NAME}_${CONDA_UNAME}.yml"
    if [[ -z ${__MAMBA_ENV_DOWNLOAD+x} ]]; then
        # use local file
        # shellcheck disable=SC2312
        __MAMBA_ENV_FILE="conda/${filename}"
    else
        __MAMBA_ENV_FILE="${HOME}/${filename}"
        github_download_file_to UniExeterRSE gw4-isambard-3-practical-workshop main "bootstrap/conda/${filename}" "${__MAMBA_ENV_FILE}"
    fi
}

mamba_env_install() {
    get_conda_env_file
    if [[ -d ${PREFIX} ]]; then
        "${MAMBA_ROOT_PREFIX}/bin/mamba" env update -f "${__MAMBA_ENV_FILE}" -p "${PREFIX}" -y --prune
    else
        "${MAMBA_ROOT_PREFIX}/bin/mamba" env create -f "${__MAMBA_ENV_FILE}" -p "${PREFIX}" -y
    fi
    if [[ -n ${__MAMBA_ENV_DOWNLOAD+x} ]]; then
        rm -f "${__MAMBA_ENV_FILE}"
    fi
}

mamba_env_uninstall() {
    rm -rf "${PREFIX}"
}

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
    # shellcheck disable=SC1090
    . ~/.bashrc || true

    print_double_line
    echo 'Generating SSH key and login to GitHub'
    ssh_keygen_and_login
}

main
