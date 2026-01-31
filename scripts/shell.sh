#!/usr/bin/env bash

setup_zsh() {
  echo "Configuring Zsh with Starship prompt"

  # Get the path to zsh
  local zsh_path
  zsh_path=$(command -v zsh)

  if [[ -z "$zsh_path" ]]; then
    echo "  ✗ Zsh not found. Please install zsh first."
    return 1
  fi

  # Plugin install directory
  local plugin_dir="$HOME/.zsh/plugins"
  if [[ ! -d "$plugin_dir" ]]; then
    run "mkdir -p $plugin_dir"
  fi

  # Install Starship prompt (idempotent - only installs if not present)
  if ! command -v starship &>/dev/null; then
    echo "  Installing Starship prompt..."
    run "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
  else
    echo "  ✓ Starship already installed"
  fi

  # Install zsh-syntax-highlighting
  local syntax_dir="$plugin_dir/zsh-syntax-highlighting"
  if [[ ! -d "$syntax_dir" ]]; then
    echo "  Installing zsh-syntax-highlighting..."
    run "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_dir"
  else
    echo "  ✓ zsh-syntax-highlighting already installed"
  fi

  # Install zsh-autosuggestions
  local autosuggestions_dir="$plugin_dir/zsh-autosuggestions"
  if [[ ! -d "$autosuggestions_dir" ]]; then
    echo "  Installing zsh-autosuggestions..."
    run "git clone https://github.com/zsh-users/zsh-autosuggestions $autosuggestions_dir"
  else
    echo "  ✓ zsh-autosuggestions already installed"
  fi

  # Check if zsh is in /etc/shells (idempotent)
  if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
    echo "  Adding $zsh_path to /etc/shells..."
    run "echo '$zsh_path' | sudo tee -a /etc/shells"
  else
    echo "  ✓ $zsh_path already in /etc/shells"
  fi

  # Change default shell to zsh (idempotent - only changes if different)
  # Note: This only affects the user's shell, not omarchy's bash setup
  local current_shell="${SHELL}"
  if [[ "$current_shell" != "$zsh_path" ]]; then
    echo "  Changing default shell from $current_shell to $zsh_path..."
    echo "  Note: This only affects your user shell, omarchy will continue using bash"
    run "chsh -s $zsh_path"
    echo "  ✓ Default shell changed to zsh. Please log out and log back in for changes to take effect."
  else
    echo "  ✓ Zsh is already the default shell"
  fi
}
