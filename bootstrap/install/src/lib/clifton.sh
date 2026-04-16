BINDIR="${__OPT_ROOT}/bin"

# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"

clifton_install() {
    case "${__OSTYPE}-${__ARCH}" in
        Darwin-arm64) filename="clifton-macos-aarch64" ;;
        Darwin-x86_64) filename="clifton-macos-x86_64" ;;
        Linux-x86_64) filename="clifton-linux-musl-x86_64" ;;
        Linux-aarch64) filename="clifton-linux-musl-aarch64" ;;
        *) exit 1 ;;
    esac
    url="https://github.com/isambard-sc/clifton/releases/latest/download/${filename}"

    mkdir -p "${BINDIR}"
    if command -v curl > /dev/null; then
        curl -fL "${url}" -o "${BINDIR}/clifton"
    elif command -v wget > /dev/null; then
        wget "${url}" -O "${BINDIR}/clifton"
    fi
    chmod +x "${BINDIR}/clifton"
}

clifton_uninstall() {
    rm -f "${BINDIR}/clifton"
}
