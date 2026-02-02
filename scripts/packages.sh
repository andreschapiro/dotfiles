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

# Setup mise with full runtimes (for server)
setup_mise_runtimes_full() {
  if ! command -v mise &>/dev/null; then
    echo "  Warning: mise not found, skipping runtime setup"
    return 1
  fi
  
  echo "  Setting up mise runtimes (full)..."
  
  # JavaScript/TypeScript
  run "mise use --global node@lts"
  run "mise use --global bun@latest"
  
  # Systems languages
  run "mise use --global go@latest"
  run "mise use --global rust@latest"
  run "mise use --global zig@latest"
  
  # Scripting languages
  run "mise use --global python@latest"
  run "mise use --global ruby@latest"
  
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

setup_server_packages() {
  echo "==> Installing packages for Arch Linux Server"
  
  # Base development packages (needed for AUR and compiling)
  local base_packages=(
    base-devel     # Build tools (gcc, make, etc.)
    git
    wget
    curl
    # Build dependencies for mise runtimes (Ruby, Python, etc.)
    openssl        # Required by Ruby, Python, Node
    readline       # Required by Ruby, Python
    zlib           # Required by Ruby, Python
    libyaml        # Required by Ruby
    libffi         # Required by Ruby, Python
    sqlite         # Required by Python
    xz             # Required by Python
    tk             # Required by Python (tkinter)
    bzip2          # Required by Python
  )
  
  echo "  Installing base development packages..."
  for package in "${base_packages[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      echo "  Already installed: $package"
    else
      echo "  Installing $package..."
      run "sudo pacman -S --noconfirm $package"
    fi
  done
  
  # Install yay (AUR helper)
  install_yay
  
  local packages=(
    # Core tools
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
    jq             # JSON processor
    # Documentation
    man-db
    man-pages
    # Archive utilities
    unzip
    zip
    tar
    gzip
    # System monitoring
    htop
    btop
    ncdu           # Disk usage analyzer
    # Networking
    iproute2       # ip, ss, etc.
    bind           # dig, nslookup (DNS utilities)
    rsync
    # Scheduled tasks
    cronie
    # Security
    ufw            # Firewall
    fail2ban       # Brute force protection
    # Server-specific
    openssh        # SSH server
    docker         # Container runtime
    docker-compose # Container orchestration
    tailscale      # Mesh VPN
    # Useful extras
    tree
    lazygit
  )
  
  echo "  Installing packages from official repos..."
  for package in "${packages[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      echo "  Already installed: $package"
    else
      echo "  Installing $package..."
      run "sudo pacman -S --noconfirm $package"
    fi
  done
  
  # Install AUR packages
  local aur_packages=(
    lazydocker     # TUI for Docker management
  )
  
  echo "  Installing packages from AUR..."
  for package in "${aur_packages[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      echo "  Already installed: $package"
    else
      echo "  Installing $package from AUR..."
      run "yay -S --noconfirm $package"
    fi
  done
  
  # Install Ghostty terminfo (for SSH from Ghostty terminal)
  install_ghostty_terminfo
  
  # Enable and start services
  echo "  Enabling services..."
  run "sudo systemctl enable --now sshd"
  run "sudo systemctl enable --now cronie"
  run "sudo systemctl enable --now tailscaled"
  run "sudo systemctl enable --now docker"
  
  # Add current user to docker group
  echo "  Adding user to docker group..."
  run "sudo usermod -aG docker $USER"
  
  # Configure UFW firewall (allow SSH, Tailscale)
  echo "  Configuring firewall..."
  run "sudo ufw default deny incoming"
  run "sudo ufw default allow outgoing"
  run "sudo ufw allow ssh"
  run "sudo ufw allow in on tailscale0"
  run "sudo ufw --force enable"
  
  # Install mise for runtime management
  install_mise
  setup_mise_runtimes_full
  
  # Install opencode
  if ! command -v opencode &>/dev/null; then
    echo "  Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
  else
    echo "  Already installed: opencode"
  fi
  
  echo "  Server package installation complete"
  echo ""
  echo "  NOTE: Log out and back in for docker group membership to take effect"
}

# Install yay AUR helper
install_yay() {
  if command -v yay &>/dev/null; then
    echo "  Already installed: yay"
    return 0
  fi
  
  echo "  Installing yay (AUR helper)..."
  local tmp_dir=$(mktemp -d)
  run "git clone https://aur.archlinux.org/yay.git $tmp_dir/yay"
  run "cd $tmp_dir/yay && makepkg -si --noconfirm"
  run "rm -rf $tmp_dir"
  echo "  yay installed successfully"
}

# Install Ghostty terminfo for proper terminal support when SSH'ing from Ghostty
install_ghostty_terminfo() {
  # Check if already installed
  if infocmp xterm-ghostty &>/dev/null 2>&1; then
    echo "  Already installed: ghostty terminfo"
    return 0
  fi
  
  echo "  Installing Ghostty terminfo..."
  
  # Ensure ncurses is installed (provides tic)
  if ! command -v tic &>/dev/null; then
    run "sudo pacman -S --noconfirm ncurses"
  fi
  
  # Install from dotfiles terminfo directory
  local terminfo_file="${DOTS_FOLDER}/terminfo/xterm-ghostty.terminfo"
  
  if [[ -f "$terminfo_file" ]]; then
    run "tic -x $terminfo_file"
    echo "  Ghostty terminfo installed successfully"
  else
    echo "  Warning: Ghostty terminfo not found at $terminfo_file"
    echo "  Run 'infocmp -x xterm-ghostty > terminfo/xterm-ghostty.terminfo' on a machine with Ghostty"
    return 1
  fi
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
    tree-sitter-cli # Parser generator CLI (required for nvim-treesitter main branch)
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

