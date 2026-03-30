# Bash configuration
# This file augments the default omarchy bashrc

# Source the system bashrc if it exists (omarchy default)
if [[ -f /etc/bash.bashrc ]]; then
  source /etc/bash.bashrc
fi

# If not in omarchy, source the user's default bashrc
if [[ -f ~/.bashrc.backup ]]; then
  source ~/.bashrc.backup
fi

# Environment Variables
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='chromium'

# Go environment (matching zsh config)
export GOPATH=$HOME/go
if command -v go &>/dev/null; then
  export GOROOT="$(go env GOROOT)"
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi

# Add local bin to PATH
export PATH=$HOME/.local/bin:$PATH

# pnpm global bin
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
export PATH="$PNPM_HOME:$PATH"

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Better directory navigation
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar

# Aliases (matching functionality from zsh)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Modern replacements if available
if command -v eza &>/dev/null; then
  # alias ls='eza --color=always --group-directories-first'
  alias ll='eza -la --color=always --group-directories-first'
  alias la='eza -a --color=always --group-directories-first'
  alias lt='eza -aT --color=always --group-directories-first'
fi

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# Tree function (matching zsh config)
t() {
  # Defaults to 3 levels deep, do more with `t 5` or `t 1`
  # pass additional args after
  tree -I '.git|node_modules|.DS_Store' --dirsfirst --filelimit 15 -L ${1:-3} -aC $2
}

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gs='git status'
alias gd='git diff'

# Directory aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Initialize starship prompt (similar to p10k functionality)
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# Initialize zoxide if available (modern cd replacement)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi

# Initialize fzf if available
if command -v fzf &>/dev/null; then
  source /usr/share/fzf/key-bindings.bash 2>/dev/null || true
  source /usr/share/fzf/completion.bash 2>/dev/null || true
fi

# Local customizations
if [[ -f ~/.bashrc.local ]]; then
  source ~/.bashrc.local
fi
