#!/usr/bin/env bash

# Package installation script
# Handles package installation for macOS (Homebrew) and Arch Linux (pacman)

# Install mise (runtime version manager)
install_mise() {
  if command -v mise &>/dev/null; then
    echo "  Already installed: mise"
    return 0
  fi
  
  echo "  Installing mise..."
  curl https://mise.run | sh
  
  # Add mise to path for current session
  export PATH="$HOME/.local/bin:$PATH"
  
  echo "  mise installed successfully"
}

# Setup mise with common runtimes
setup_mise_runtimes() {
  if ! command -v mise &>/dev/null; then
    echo "  Warning: mise not found, skipping runtime setup"
    return 1
  fi
  
  echo "  Setting up mise runtimes..."
  
  # Install Node.js LTS
  run "mise use --global node@lts"
  
  # Install Go (latest)
  run "mise use --global go@latest"
  
  echo "  mise runtimes configured"
}

setup_arch_packages() {
  echo "==> Installing packages for Linux (Arch/Omarchy)"
  
  local packages=(
    # Core tools
    git
    neovim
    tmux
    zsh
    stow
    # Modern CLI tools
    starship       # Cross-shell prompt
    fzf            # Fuzzy finder
    zoxide         # Smarter cd
    eza            # Modern ls with icons
    ripgrep        # Modern grep
    fd             # Modern find
    bat            # Modern cat with syntax highlighting
    # Development tools
    github-cli     # GitHub CLI (gh)
    luarocks       # Lua package manager (for neovim plugins)
    fontconfig     # Font configuration
  )
  
  for package in "${packages[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      echo "  Already installed: $package"
    else
      echo "  Installing $package..."
      run "sudo pacman -S --noconfirm $package"
    fi
  done
  
  # Install mise for runtime management
  install_mise
  
  # Install opencode
  if ! command -v opencode &>/dev/null; then
    echo "  Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
  else
    echo "  Already installed: opencode"
  fi
  
  echo "  Package installation complete"
}

setup_mac_packages() {
  echo "==> Installing packages for macOS"
  
  # Check for Homebrew
  if ! command -v brew &>/dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to path for current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  local packages=(
    # Core tools
    git
    neovim
    tmux
    zsh
    stow
    # Modern CLI tools
    starship       # Cross-shell prompt
    fzf            # Fuzzy finder
    zoxide         # Smarter cd
    eza            # Modern ls with icons
    ripgrep        # Modern grep
    fd             # Modern find
    bat            # Modern cat with syntax highlighting
    # Development tools
    gh             # GitHub CLI
    luarocks       # Lua package manager (for neovim plugins)
    fontconfig     # Font configuration
  )

  for package in "${packages[@]}"; do
    if brew list "$package" &>/dev/null; then
      echo "  Already installed: $package"
    else
      echo "  Installing $package..."
      run "brew install $package"
    fi
  done

  # Install mise for runtime management
  install_mise
  
  # Install opencode
  if ! command -v opencode &>/dev/null; then
    echo "  Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
  else
    echo "  Already installed: opencode"
  fi
  
  echo "  Package installation complete"
}

