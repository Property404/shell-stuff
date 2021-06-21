# 'Public' .bashrc
# shellcheck shell=bash

# Station-specific definitions(work/home/vm/etc)
if [ -f "$HOME/.bashrc_private" ]; then
    source "$HOME/.bashrc_private"
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
export VISUAL='vim'
export PAGER='less'

# ls habits
alias l="ls --color=auto -A"
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
alias rm='trash-put'

# Lax aliases
alias vim="lax gvim -v" # Allows clipboard copying on Fedora
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

# A 'hex editor'
function xvim() {
    xxd "$@" | vipe | xxd -r | sponge "$@"
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
    if ! args=$(lax -Dp -- "$@"); then 
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
    cd "$(sed "$1" <(pwd))"
}

# Change tab title
function title() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}
