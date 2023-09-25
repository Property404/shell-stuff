#!/usr/bin/env bash
# 'Public' .bashrc

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

# ls habits
alias l="ls --color=auto"
alias la="ls --color=auto -A"

# Danger: SSH without checking key
alias unsafe_ssh="ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'"
alias unsafe_scp="scp -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'"

alias update_all="sudo dnf update --refresh -y && sudo flatpak update -y"

# CD conveniences
shopt -s autocd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."

function maybelax() {
    if command -v lax > /dev/null; then
        lax "${@}"
    else
        "${@}"
    fi
}

# Less dangerous `rm`
alias rm='maybelax trash-put'

# Lax aliases
if command -v gvim > /dev/null; then
    # Allows clipboard copying on Fedora
    alias vim="maybelax gvim -v "
    alias vimdiff="maybelax gvimdiff -v"
else
    alias vim="maybelax vim"
    alias vimdiff="maybelax vimdiff"
fi
alias rg="maybelax rg"
alias grep="maybelax grep --color=auto"
alias ls="maybelax ls --color=auto"

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
alias bim="vim"
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
    kvs snip "${@}"
}

# Very cool `cd` wrapper
# `pd` allows going backwords like pushd/popd, but`fd` allows you to also go
# forward in time
# Additionally, it uses `lax` so you can teleport to child directories
declare -a CD2_BACK_STACK=();
declare -a CD2_FORWARD_STACK=();
function cd() {
    local args;
    if command -v lax > /dev/null; then
        if ! args=$(lax -Dp "$@"); then
            return 1
        fi
    else
        args="$*"
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
    command cd "$last_dir" || return 1
}

function fd() {
    if [ "${#CD2_FORWARD_STACK[@]}" -eq 0 ]; then
        echo "Empty forward stack"
        return 1
    fi
    local last_dir=${CD2_FORWARD_STACK[-1]};
    unset "CD2_FORWARD_STACK[-1]"
    CD2_BACK_STACK+=("$(pwd)")
    command cd "$last_dir" || return 1
}

# Edit directory with regex
function rd() {
    if [ "${#@}" -eq "0" ]; then
        echo "Requires one argument" 1>&2
        return 1
    fi
    cd "$(sed "s/${1}/${2}/g" <(pwd))" || return 1
}

# Change tab title
function title() {
    declare orig;
    if [[ -z "$orig" ]]; then
        orig=$PS1
    fi
    TITLE="\[\e]2;$*\a\]"
    PS1=${orig}${TITLE}
}

# Dumb little todo list
function todo {
    if command -v notes > /dev/null; then
        notes todo
    else
        vim ~/Documents/todo
    fi
}

# Station-specific definitions(work/home/vm/etc)
if [ -f "$HOME/.bashrc_post" ]; then
    source "$HOME/.bashrc_post"
fi
