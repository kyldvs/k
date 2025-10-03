# Minimal zsh configuration
# Less but better - no plugins, frameworks, or complexity

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Completion system
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Better prompt (simple, informative)
PROMPT='%F{blue}%~%f %# '
RPROMPT='%F{green}%?%f'

# Useful keybindings
bindkey '^R' history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history

# Source aliases if they exist
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# Load local config if exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
