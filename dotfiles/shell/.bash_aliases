# Shell aliases for bash
# Less but better - useful, non-opinionated aliases

# Directory listing
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias l='ls -CF'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Disk usage
alias du='du -h'
alias df='df -h'

# Make directories with parents
alias mkdir='mkdir -p'

# Git shortcuts (if git is available)
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# Local aliases
[ -f ~/.bash_aliases.local ] && source ~/.bash_aliases.local
