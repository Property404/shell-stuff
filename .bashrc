# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias vim='/usr/bin/nvim'
alias ddg='elinks https://duckduckgo.com'
alias oscbook='elinks http://pages.cs.wisc.edu/~remzi/OSTEP/'
alias mc='ranger'
alias python='python3'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export PS1='\W \$ '


alias rmswap='rm ~/.local/share/nvim/swap/*'
