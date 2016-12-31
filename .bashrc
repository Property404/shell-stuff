set -o vi
shopt -s expand_aliases

# Aliases becuase of lack of i key
alias vm="vim"
alias gedt="gedit"
alias gt="git"
alias commt="commit"
alias :q="exit"

# Debian-based only
alias supdate="sudo apt-get update"
alias supgrade="sudo apt-get dist-upgrade"
alias sgetpkg="sudo apt-get install"

# Fun stuff
fortune -s
