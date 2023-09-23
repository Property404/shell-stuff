#!/usr/bin/env bash
# Bootstrap a new system
set -e

error() {
    echo -e "\e[31merror: ${*}\e[0m"
    return 1
}

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

    local deps
    deps="${PACKAGES} \\
        git tmux moreutils vim make gcc ripgrep curl"
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        deps+=" trash-cli file nodejs "
        if [[ -n "${FEAT_GUI}" ]]; then
            deps+=" gvim "
        fi
    fi

    local update;
    local install;
    local use_sudo=1
    if command -v dnf > /dev/null; then
        update="dnf update --refresh -y"
        install="dnf install -y"
        deps+=" openssl-devel diffutils "
    elif command -v apt-get > /dev/null; then
        update="apt-get update && apt-get upgrade -y"
        install="apt-get install -y"
        deps+=" libssl-dev "
    elif command -v brew > /dev/null; then
        # Github CI fix
        brew update
        brew remove 'node@18' || true

        update="brew update && brew upgrade"
        install="brew install -y"
        deps+=" gnu-sed node "
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

install_notes() {
    log "Installing Notes"
    BASH_COMPLETIONS_DIR=~/.bash_completion.d\
        cargo install --git https://github.com/Property404/notes
}

main() {
    local -r USAGE="Usage: $(basename "${0}") [-h] --profile <profile>"
    local -r HELP="Set up a system for the first time

$USAGE

Help:
    -p, --profile Choose which profile to use
    -h, --help	  Display this message"

    local profile
    while true; do
        case "$1" in
            -p | --profile ) profile="${2}"; shift 2 ;;
            -h | --help ) echo "$HELP"; return 0 ;;
            -- ) shift; break ;;
            -* ) error "Unrecognized option: $1\n$USAGE" ;;
            * ) break ;;
        esac
    done

    set -u

    if [[ -z "${profile}" ]]; then
        error "Please select a profile\n$USAGE"
    fi
    if [[ ! -f "./profiles/${profile}" ]]; then
        error "Profile '${profile}' does not exist"
    fi
    log "Using profile '${profile}'"
    source "./profiles/${profile}"

    install_system_dependencies
    install_dagan_utils
    install_rust
    if [[ -n "${FEAT_CARGO_DEV_TOOLS}" ]]; then
        install_rust_cargo_tools
    fi
    install_lax
    install_dot_files
    install_vim_plug
    if [[ -n "${FEAT_NOTES}" ]]; then
        install_notes
    fi
    log "System has been set up!"
}

main "${@}"
