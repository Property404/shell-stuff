# 'Public' .bashrc
# shellcheck shell=bash

# Station-specific definitions(work/home/vm/etc)
if [ -f "$HOME/.bashrc_pre" ]; then
    source "$HOME/.bashrc_pre"
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

# User specific environment
# shellcheck disable=SC2076
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Disable annoying flow control shit
stty -ixon

# Less annoying prompt
export PS1='\W \$ '

export EDITOR='vim'
export VISUAL="vim"
export SYSTEMD_EDITOR='vim'
export PAGER='less'

# Because I keep accidentally rebooting
alias reboot='echo "Woah slow down there pardner...if you actually want to reboot, use sudo"'

# Because vim terminals
alias :q='exit'
alias :Q='exit'

alias r=". ranger"

# ls habits
alias l="ls --color=auto"
alias la="ls --color=auto -A"

# Danger: SSH without checking key
alias unsafe_ssh="ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'"
alias unsafe_scp="ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'"

alias update_all="sudo dnf update --refresh -y && sudo flatpak update -y"

# Ten lines is too short usually
alias head='head -n 25'

# CD conveniences
shopt -s autocd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."

# Less dangerous `rm`
alias rm='lax trash-put'

# Lax aliases
alias vim="lax 'gvim|vim' -v " # Allows clipboard copying on Fedora
alias vimdiff="lax 'gvimdiff|vimdiff' -v" # Allows clipboard copying on Fedora
alias rg="lax rg"
alias grep="lax grep --color=auto"
alias ls="lax ls --color=auto"

# Because --color=always is a mouthful
alias less="less -r"
alias cargo="cargo --color=always"
alias cgrep="grep --color=always"
alias crg="rg --color=always"

# Spelling mistakes
alias sl="ls"
alias gre="grep"
alias grp="grep"
alias kilall="killall"
alias viim="vim"
alias cago="cargo"
alias caergo="cargo"
alias Cargo="cargo"
# Old habits die hard
# Precursor to lax
vimat() {
    echo "Use lax, doofus"
}

# A 'hex editor'
function xvim() {
    xxd "$@" | vipe | xxd -r | sponge "$@"
}

function xvimdiff {
    vimdiff <(xxd "$1") <(xxd "$2")
}

function xdiff {
    diff <(xxd "$1") <(xxd "$2")
}

# Copy code snippets, etc, stored in KVS (dagan-utils)
function snip() {
    kvs get "${@}" | wl-copy -n
}

# Very cool `cd` wrapper
# `pd` allows going backwords like pushd/popd, but`fd` allows you to also go
# forward in time
# Additionally, it uses `lax` so you can teleport to child directories
declare -a CD2_BACK_STACK=();
declare -a CD2_FORWARD_STACK=();
function cd() {
    local args;
    if ! args=$(lax -Dp "$@"); then
        return 1
    fi
    prevdir="$(pwd)"
    command cd "${args}" > /dev/null && CD2_BACK_STACK+=("$prevdir") && CD2_FORWARD_STACK=()
}

function pd() {
    if [ "${#CD2_BACK_STACK[@]}" -eq 0 ]; then
        echo "Empty back stack"
        return 1
    fi
    local last_dir=${CD2_BACK_STACK[-1]};
    unset "CD2_BACK_STACK[-1]"
    CD2_FORWARD_STACK+=("$(pwd)")
    command cd "$last_dir"
}

function fd() {
    if [ "${#CD2_FORWARD_STACK[@]}" -eq 0 ]; then
        echo "Empty forward stack"
        return 1
    fi
    local last_dir=${CD2_FORWARD_STACK[-1]};
    unset "CD2_FORWARD_STACK[-1]"
    CD2_BACK_STACK+=("$(pwd)")
    command cd "$last_dir"
}

# Edit directory with regex
function rd() {
    if [ "${#@}" -eq "0" ]; then
        echo "Requires one argument" 1>&2
        return 0
    fi
    cd $(sed "s/${1}/${2}/g" <(pwd))
}

# Change tab title
function title() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}

# Little todo list
function todo {
    vim ~/Documents/todo
}

# Note taking script
function notes() {
    path="$HOME/.config/notes/"
    target=$1
    if [ ! "$target" ]; then
        target="*"
    fi
    target=$(lax -p "@${path}**/${target}")
    if [ -f "${target}" ]; then
        lax 'gvim|vim' -v "${target}"
    else
        echo "Note '$1' doesn't exist."
        while true; do
            read -rp "Would you like to create it(y/n)?" yn
            case "${yn}" in 
                [Yy]* ) touch "${path}${1}"; lax 'gvim|vim' -v "${path}${1}"; break;;
                [Nn]* ) break;;
            esac
        done
    fi
}

# Station-specific definitions(work/home/vm/etc)
if [ -f "$HOME/.bashrc_post" ]; then
    source "$HOME/.bashrc_post"
fi
