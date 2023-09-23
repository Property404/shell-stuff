#!/usr/bin/env bash
# Bootstrap a new system
set -e

log() {
    echo -e "\e[32m${*}\e[0m"
}

backup_file() {
    local -r file="$1"
    if [[ ! -e "$file" ]]; then
        return 0
    fi

    local backup="${file}.bak"
    while [[ -e "${backup}" ]]; do
        backup="${backup}.bak"
    done
    cp "${file}" "${backup}"
}

install_system_dependencies() {
    local -r marker="/tmp/.dev.dagans.shell-stuff.updated-dependencies"
    if [[ -e "${marker}" ]]; then
        return 0
    fi
    log "Installing system dependencies"

    local use_sudo=1
    local -r linting_programs="shellcheck black pylint gem yamllint"
    local -r common_deps="${linting_programs} \\
        git tmux moreutils vim make gcc ripgrep curl"
    local -r linux_deps="$common_deps trash-cli file nodejs"

    local update;
    local install;
    local deps;
    if command -v dnf > /dev/null; then
        update="dnf update --refresh -y"
        install="dnf install -y"
        deps="$linux_deps openssl-devel diffutils"
    elif command -v apt-get > /dev/null; then
        update="apt-get update && apt-get upgrade -y"
        install="apt-get install -y"
        deps="$linux_deps libssl-dev"
    elif command -v brew > /dev/null; then
        # Github CI fix
        brew update
        brew remove 'node@18' || true

        update="brew update && brew upgrade"
        install="brew install -y"
        deps="$common_deps gnu-sed node"
        # Brew doesn't use sudo
        use_sudo=
    else
        echo "Could not install dependencies - unknown system"
        return 1
    fi

    local -r command="${update} && ${install} ${deps}"
    echo "${command}"
    if [[ -n "${use_sudo}" ]]; then
        sudo bash -c "${command}"
    else
        bash -c "${command}"
    fi

    touch "${marker}"
}

install_dagan_utils() {
    if ! command -v peval > /dev/null; then
        log "Installing dagan-utils"
        pushd /tmp/
        git clone https://github.com/Property404/dagan-utils
        cd dagan-utils
        make install
        popd
    fi
}

install_rust() {
    if ! command -v rustup > /dev/null; then
        log "Installing rust"
        curl --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
    fi
    source "$HOME/.cargo/env"
}

install_rust_cargo_tools() {
    log "Installing rust cargo tools"
    cargo install cargo-edit cargo-audit
}

install_lax() {
    if ! command -v lax > /dev/null; then
        log "Installing lax"
        cargo install --git https://github.com/Property404/lax
    fi
}

install_dot_files() {
    local -a files=(\
    ".bashrc" ".vimrc" ".tmux.conf" ".gitconfig" ".gitexclude"\
    .local/bin/* ".bash_completion" )
    for file in "${files[@]}"; do
        home_file="${HOME}/${file}"
        if [[ ! -e "$home_file" ]] || ! diff "$file" "$home_file" > /dev/null; then
            log "Installing ${file}"
            backup_file "$HOME/${file}"
            cp "${file}" "$HOME/${file}"
        fi
    done
}

install_vim_plug() {
    log "Installing VimPlug"
    curl --tlsv1.3 -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # Vim will complain about plugins not found, so pipe `yes`
    yes | vim +PlugInstall +qall > /dev/null
}

main() {
    local -r USAGE="Usage: $(basename "${0}") [-qh]"
    local -r HELP="Set up a system for the first time

$USAGE

Help:
    -q, --quick Skip long steps
    -h, --help	Display this message"

    local quick
    while true; do
        case "$1" in
            -q | --quick ) quick=1; shift ;;
            -h | --help ) echo "$HELP"; return 0 ;;
            -- ) shift; break ;;
            -* ) echo -e "Unrecognized option: $1\n$USAGE" >&2; return 1 ;;
            * ) break ;;
        esac
    done

    install_system_dependencies
    install_dagan_utils
    install_rust
    if [[ -z "${quick}" ]]; then
        install_rust_cargo_tools
    fi
    install_lax
    install_dot_files
    install_vim_plug
}

main "${@}"
