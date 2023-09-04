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
    log "Installing system dependencies"
    if command -v dnf > /dev/null; then
        local -r dependencies="git tmux moreutils vim trash-cli"
        sudo bash -c "dnf update -y && dnf install -y $dependencies"
    fi
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
        cargo install --path .
        popd
    fi
}

install_dot_files() {
    local -a files=(".bashrc" ".vimrc" ".tmux.conf")
    for file in "${files[@]}"; do
        home_file="${HOME}/${file}"
        if [[ ! -e "$home_file" ]] || ! diff "$file" "$home_file"; then
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
