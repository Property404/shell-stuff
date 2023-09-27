#!/usr/bin/env bash
# Bootstrap a new system
set -e

error() {
    echo -e "\e[31merror: ${*}\e[0m"
    return 1
}

warn() {
    echo -e "\e[33mwarning: ${*}\e[0m"
}

log() {
    echo -e "\e[32m${*}\e[0m"
}

add_pkgs() {
    local -r systype="$1"
    if [[ "${systype}" == "macos" ]]; then
        if [[ "${OSTYPE}" != "darwin" ]]; then
            return 0
        fi
    elif [[ "${systype}" == "linux" ]]; then
        if [[ "${OSTYPE}" != "linux-gnu" ]]; then
            return 0
        fi
    elif [[ "${systype}" == "dnf" ]]; then
        if ! command -v dnf > /dev/null; then
            return 0
        fi
    elif [[ "${systype}" == "apt" ]]; then
        if ! command -v apt-get > /dev/null; then
            return 0
        fi
    elif [[ "${systype}" != "all" ]] ; then
        error "Unknown system type: ${systype}"
    fi
    shift 1
    PACKAGES+=" ${*} "
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
    local -r skip_update="${1}"

    add_pkgs all "git tmux moreutils vim make ripgrep curl"
    add_pkgs linux "trash-cli file nodejs pkg-config"
    add_pkgs dnf "diffutils"
    add_pkgs macos "gnu-sed node"
    if [[ -n "${FEAT_NVIM}" ]]; then
        add_pkgs all "nvim"
    fi
    if [[ -n "${FEAT_RUST_DEV}" ]]; then
        add_pkgs all "gcc"
        add_pkgs dnf "openssl-devel"
        add_pkgs apt "libssl-dev"
    fi
    if [[ -n "${FEAT_GENERATE_KEYS}" ]]; then
        add_pkgs dnf "openssh"
        add_pkgs apt "ssh"
    fi

    local update;
    local install;
    local use_sudo=1
    if command -v dnf > /dev/null; then
        update="dnf update --refresh -y"
        install="dnf install -y"
    elif command -v apt-get > /dev/null; then
        update="apt-get update && apt-get upgrade -y"
        install="apt-get install -y"
    elif command -v brew > /dev/null; then
        # Github CI fix
        brew update
        brew remove 'node@18' || true

        update="brew update && brew upgrade"
        install="brew install"
        # Brew doesn't use sudo
        use_sudo=
    else
        error "Could not install dependencies - unknown system"
    fi

    local command=""
    if [[ -z "${skip_update}" ]]; then
        command+="${update} && "
    fi
    command+="${install} ${PACKAGES}"
    if [[ -n "${LATE_PACKAGES}" ]]; then
        command+=" && ${install} ${LATE_PACKAGES}"
    fi
    echo "${command}"
    if [[ -n "${use_sudo}" ]]; then
        sudo bash -c "${command}"
    else
        bash -c "${command}"
    fi
}

install_ruby_packages() {
    if [[ -z "$RUBY_PACKAGES" ]]; then
        log "Installing gems: $RUBY_PACKAGES"
        gem install "$RUBY_PACKAGES"
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
        curl --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
    fi
    source "$HOME/.cargo/env"
}

install_rust_cargo_tools() {
    log "Installing rust cargo tools"
    cargo install cargo-edit cargo-audit rusty-tags
}

install_lax() {
    if ! command -v lax > /dev/null; then
        log "Installing lax"
        cargo install --git https://github.com/Property404/lax
    fi
}

install_dotfiles() {
    mkdir -p ~/.local/bin/
    mkdir -p ~/.config/nvim/
    pushd dotfiles
    local -a files=(\
    ".bashrc" ".vimrc" ".tmux.conf" ".gitconfig" ".gitexclude"\
    .local/bin/* ".bash_completion" ".config/nvim/init.vim" )
    for file in "${files[@]}"; do
        home_file="${HOME}/${file}"
        if [[ ! -e "$home_file" ]] || ! diff "$file" "$home_file" > /dev/null; then
            log "Installing ${file}"
            backup_file "$HOME/${file}"
            cp "${file}" "$HOME/${file}"
        fi
    done
    touch ~/.gitconfig_custom
    popd
}

install_vim_plug() {
    log "Installing VimPlug"
    mkdir -p ~/.vim/autoload/
    curl --tlsv1.2 -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # Vim will complain about plugins not found, so pipe `yes`
    yes | vim +PlugInstall +qall > /dev/null
}

install_notes() {
    log "Installing Notes"
    if ! command -v notes > /dev/null; then
        BASH_COMPLETIONS_DIR=~/.bash_completion.d\
            cargo install --git https://github.com/Property404/notes
    fi
}

add_gui_packages() {
    log "Adding GUI packages"
    if [[ "${OSTYPE}" == "darwin" ]]; then
        log "DE: Aqua"
        # Nothing to do
    elif [[ "${OSTYPE}" == "linux-gnu" ]]; then
        add_pkgs linux "gvim"

        if [[ "${XDG_CURRENT_DESKTOP}" == "GNOME" ]]; then
            log "DE: Gnome"
            add_pkgs linux "gnome-tweaks"
        elif [[ "${XDG_CURRENT_DESKTOP}" == "KDE" ]]; then
            log "DE: KDE"
            # Nothing to do
        else
            error "Could not determine DE type"
        fi

        if [[ "${XDG_SESSION_TYPE}" == "x11" ]]; then
            add_pkgs linux "xsel"
        elif [[ "${XDG_SESSION_TYPE}" == "wayland" ]]; then
            add_pkgs linux "wl-clipboard"
        else
            error "Could not determine session type"
        fi
    else
        error "Could not determine OS type"
    fi
}

set_up_de() {
    log "Setting up desktop environment"
    if [[ "${XDG_CURRENT_DESKTOP}" == "GNOME" ]]; then
        log "DE: Gnome"
        # Dark mode
        gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
        # We use trash-cli for rm, so trash will definitely fill up
        gsettings set org.gnome.desktop.privacy remove-old-trash-files true
        # Remove old temporary files
        gsettings set org.gnome.desktop.privacy remove-old-temp-files true
        # Disable annoying sounds
        gsettings set org.gnome.desktop.sound event-sounds false
    elif [[ "${XDG_CURRENT_DESKTOP}" == "KDE" ]]; then
        log "DE: KDE"
        # Nothing to do
    elif [[ "${OSTYPE}" == "darwin" ]]; then
        log "DE: Aqua"
        # Nothing to do
    else
        error "Could not determine DE type"
    fi
}

set_up_firefox() {
    log "Setting up Firefox"
    cp config/user.js ~/.mozilla/firefox/*.default-release/
}

generate_ssh_keys() {
    if [[ ! -f "${HOME}/.ssh/id_ed25519.pub" ]]; then
        log "Generating SSH keys"
        ssh-keygen -t ed25519 \
            -C "dontemailme@dagans.dev" \
            -q -f "$HOME/.ssh/id_ed25519" -N ""
    fi
}

main() {
    local -r USAGE="Usage: $(basename "${0}") [-h] --profile <profile>"
    local -r HELP="Set up a system for the first time

$USAGE

Help:
    -p, --profile Choose which profile to use
    --skip-update Skip updating system packages
    -h, --help	  Display this message"

    local profile=""
    local skip_update=""
    while true; do
        case "${1}" in
            -p | --profile ) profile="${2}"; shift 2 ;;
            --skip-update ) skip_update=1; shift 1 ;;
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

    if [[ -n "${FEAT_LAX}" || -n "${FEAT_RUST_DEV}" || -n "${FEAT_NOTES}" ]]; then
        FEAT_RUST=1
    fi

    if [[ -n "${FEAT_GUI}" ]]; then
        add_gui_packages
    fi
    install_system_dependencies "${skip_update}"
    install_dagan_utils
    if [[ -n "${FEAT_RUST}" ]]; then
        install_rust
    fi
    if [[ -n "${FEAT_RUST_DEV}" ]]; then
        install_rust_cargo_tools
    fi
    if [[ -n "${FEAT_LAX}" ]]; then
        install_lax
    fi
    install_dotfiles
    install_vim_plug
    if [[ -n "${FEAT_NOTES}" ]]; then
        install_notes
    fi
    if [[ -n "${FEAT_GUI}" ]]; then
        set_up_de
        set_up_firefox
    fi
    if [[ -n "${FEAT_GENERATE_KEYS}" ]]; then
        generate_ssh_keys
    fi
    if [[ $(type -t post_bootstrap) == function ]]; then
        log "Running post-bootstrap configuration"
        post_bootstrap
    fi
    log "System has been set up!"
}

main "${@}"
