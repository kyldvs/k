# Zsh environment variables
# Loaded before .zshrc for all zsh sessions

# Path configuration
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/bin
  $path
)

# Editor
export EDITOR=vi
export VISUAL=vi

# Less configuration
export LESS='-R -i -M'
export PAGER=less

# Local environment overrides
[ -f ~/.zshenv.local ] && source ~/.zshenv.local
