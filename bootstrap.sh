#!/usr/bin/env bash
# Bootstrap a new system
set -e

log() {
    echo ">>> ${*}"
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

    local -r common_deps="git tmux moreutils vim make"
    local -r linux_deps="$common_deps trash-cli"

    local update;
    local install;
    local deps;
    if command -v dnf > /dev/null; then
        update="dnf update --refresh -y"
        install="dnf install -y"
        deps="$linux_deps"
    elif command -v apt > /dev/null; then
        update="apt-get update && apt-get upgrade -y"
        install="apt-get install -y"
        deps="$linux_deps"
    elif command -v brew > /dev/null; then
        update="brew update && brew upgrade -y"
        install="brew install -y"
        deps="$common_deps gnu-sed"
    else
        echo "Could not install dependencies - unknown system"
        return 1
    fi

    echo "${update} && ${install} ${deps}"
    sudo bash -c "${update} && ${install} ${deps}"

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
        cargo install cargo-edit
        cargo install cargo-audit
        cargo install ripgrep
    fi
}

install_lax() {
    if ! command -v lax > /dev/null; then
        log "Installing lax"
        pushd /tmp/
        git clone https://github.com/Property404/lax
        cd lax
        cargo install --path .
        popd
    fi
}

install_dot_files() {
    local -a files=(".bashrc" ".vimrc" ".tmux.conf" ".gitconfig" ".gitexclude")
    for file in "${files[@]}"; do
        home_file="${HOME}/${file}"
        if [[ ! -e "$home_file" ]] || ! diff "$file" "$home_file" > /dev/null; then
            log "Installing ${file}"
            backup_file "$HOME/${file}"
            cp "${file}" "$HOME/${file}"
        fi
    done
}

main() {
    install_system_dependencies
    install_dagan_utils
    install_rust
    install_lax
    install_dot_files
}

main
