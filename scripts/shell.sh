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

  # Install Oh My Zsh if not already installed (check for the main script file)
  if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    echo "  Installing Oh My Zsh..."
    # Remove incomplete installation if it exists
    [[ -d "$HOME/.oh-my-zsh" ]] && rm -rf "$HOME/.oh-my-zsh"
    run 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  else
    echo "  ✓ Oh My Zsh already installed"
  fi

  # Install Starship prompt (idempotent - only installs if not present)
  if ! command -v starship &>/dev/null; then
    echo "  Installing Starship prompt..."
    run "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
  else
    echo "  ✓ Starship already installed"
  fi

  # Install zsh-syntax-highlighting
  local syntax_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  if [[ ! -d "$syntax_dir" ]]; then
    echo "  Installing zsh-syntax-highlighting..."
    run "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_dir"
  else
    echo "  ✓ zsh-syntax-highlighting already installed"
  fi

  # Install zsh-autosuggestions
  local autosuggestions_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
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
