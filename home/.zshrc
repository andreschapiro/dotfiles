# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Zsh options for better symlink handling
setopt CHASE_LINKS        # Resolve symlinks to their true values when changing directory
setopt CHASE_DOTS         # Resolve .. to the physical parent directory

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# Using Starship prompt instead of Oh My Zsh theme
ZSH_THEME=""
function t() {
  # Defaults to 3 levels deep, do more with `t 5` or `t 1`
  # pass additional args after
  tree -I '.git|node_modules|.DS_Store' --dirsfirst --filelimit 15 -L ${1:-3} -aC $2
}
# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# OS detection for plugins
case "$(uname -s)" in
  Darwin*)
    # macOS-specific plugins (no z - using zoxide instead)
    plugins=(
      1password
      git
      zsh-syntax-highlighting
      zsh-autosuggestions
      zsh-bat
      node
      npm
      wd
      brew
    )
    ;;
  Linux*)
    # Linux-specific plugins (no brew, no z - using zoxide instead)
    plugins=(
      1password
      git
      zsh-syntax-highlighting
      zsh-autosuggestions
      node
      npm
      wd
    )
    ;;
  *)
    # Default plugins
    plugins=(
      git
      zsh-syntax-highlighting
      zsh-autosuggestions
    )
    ;;
esac

# Source Oh My Zsh if it exists
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source $ZSH/oh-my-zsh.sh
else
  echo "Warning: Oh My Zsh not found at $ZSH/oh-my-zsh.sh"
  echo "Run the setup script to install it: cd ~/dotfiles && ./setup.sh"
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# ponedark_vividlugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# OS-specific configurations
case "$(uname -s)" in
  Darwin*)
    # macOS - Homebrew paths
    export PATH=$PATH:/opt/homebrew/bin
    export GOPATH=$HOME/go
    export GOROOT="$(brew --prefix golang)/libexec"
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    ;;
  Linux*)
    # Linux - standard paths
    export GOPATH=$HOME/go
    if [[ -d /usr/lib/go ]]; then
      export GOROOT=/usr/lib/go
    elif [[ -d /usr/local/go ]]; then
      export GOROOT=/usr/local/go
    fi
    [[ -n "$GOROOT" ]] && export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    ;;
esac

# Common paths
if command -v npm &>/dev/null; then
  export NPMPATH="$(npm root -g 2>/dev/null)"
  [[ -n "$NPMPATH" ]] && export PATH=$PATH:$NPMPATH
fi

# Aliases
alias air='~/.air'
alias n=nvim
alias nn='NVIM_APPNAME=new-nvim nvim'

# ===== Modern CLI Tools =====

# eza (modern ls replacement with icons and colors)
if command -v eza &>/dev/null; then
  alias ls='eza --icons=always --group-directories-first'
  alias ll='eza --icons=always --group-directories-first -lh'
  alias la='eza --icons=always --group-directories-first -lha'
  alias lt='eza --icons=always --group-directories-first --tree --level=2'
  alias l='eza --icons=always --group-directories-first -lah'
fi

# fd (modern find replacement)
if command -v fd &>/dev/null; then
  alias find='fd'
fi

# ripgrep (modern grep replacement)
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# zoxide (smarter cd with frecency tracking)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# fzf (fuzzy finder)
if command -v fzf &>/dev/null; then
  # Set up fzf key bindings and fuzzy completion
  eval "$(fzf --zsh)"

  # Use fd instead of find for fzf
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # fzf color scheme (matches Starship theme)
  export FZF_DEFAULT_OPTS='
    --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
    --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
    --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
    --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
    --height=40% --layout=reverse --border --margin=1 --padding=1
  '
fi

# Initialize Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# amp
export PATH="$HOME/.local/bin:$PATH"

# mise (version manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# opencode
export PATH=$HOME/.opencode/bin:$PATH
