# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export PATH="$PATH:/home/dagan/.cargo/bin"

# Make the prompt less annoying
export PS1='\W \$ '
#prompt() {
#    PS1="$(powerline-rs --shell bash $?)"
#}
#PROMPT_COMMAND=prompt

alias stop="echo no u stop"
alias STOP="ECHO NO U STOP"
alias to_lower_case='tr "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz"'
alias to_upper_case='tr "abcdefghijklmnopqrstuvwxyz" "ABCDEFGHIJKLMNOPQRSTUVWXYZ"'

function command_not_found_handle
{
	LOWERCASE_NAME=$(echo $1 | to_lower_case)
	UPPERCASE_NAME=$(echo $1 | to_upper_case)

	if [ "$1" == "$LOWERCASE_NAME" ]
	then
		echo "bash: $LOWERCASE_NAME: command not found" 
		return 127
	fi

	if ! hash $LOWERCASE_NAME 2>/dev/null
	then
		echo "BASH: $UPPERCASE_NAME: COMMAND NOT FOUND" 
		return 127
	fi

	LOWERCASE_COMMAND=$(echo "$@" | to_lower_case)

	$LOWERCASE_COMMAND &> /tmp/blop
	cat /tmp/blop  | to_upper_case
}
