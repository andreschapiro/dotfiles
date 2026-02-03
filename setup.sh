#!/usr/bin/env bash

set -euo pipefail

DOTS_FOLDER="${HOME}/dotfiles"
DRY_RUN="${DRY_RUN:-false}"
SERVER_INSTALL="${SERVER_INSTALL:-false}"
export SERVER_INSTALL

# 1Password SSH Agent (needed for private repo access)
export SSH_AUTH_SOCK="${HOME}/.1password/agent.sock"

# Source all scripts
source scripts/filesystem.sh
source scripts/packages.sh
source scripts/fonts.sh
source scripts/shell.sh
source scripts/stow.sh
source scripts/clean.sh
source scripts/maintenance.sh
source scripts/network.sh

# OS Detection
detect_os() {
  case "$(uname -s)" in
  Darwin*)
    echo "macos"
    ;;
  Linux*)
    if [[ -f /etc/arch-release ]] || command -v pacman &>/dev/null; then
      echo "arch"
    else
      echo "linux"
    fi
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

# Helper function for running commands
run() {
  local cmd="$1"
  echo "  => $cmd"
  if [[ "$DRY_RUN" != "true" ]]; then
    eval "$cmd"
  else
    echo "     [DRY RUN - command not executed]"
  fi
}

# Show usage
usage() {
  echo "Usage: ./setup.sh [command]"
  echo ""
  echo "Commands:"
  echo "  (none)      Full setup: clean, packages, fonts, shell, stow"
  echo "  server      Server setup: packages (no GUI), shell, stow (server configs)"
  echo "  clean       Check for and clean dangling configs"
  echo "  backup      Backup current configurations"
  echo "  update      Update packages (brew/pacman, mise)"
  echo "  uninstall   Remove symlinks created by stow"
  echo "  wol         Enable Wake on LAN for all network interfaces"
  echo "  wol-status  Show Wake on LAN status for all interfaces"
  echo ""
  echo "Environment variables:"
  echo "  DRY_RUN=true  Show commands without executing"
}

# Full setup
full_setup() {
  local os="$1"
  
  echo "==> Starting dotfiles setup for ${os}"
  echo ""
  
  # Clean dangling configs first
  clean_dangling_configs
  
  # Setup based on OS
  setup_filesystem
  
  if [[ "$os" == "macos" ]]; then
    setup_mac_packages
    setup_mac_fonts
  else
    setup_arch_packages
    setup_arch_fonts
  fi
  
  setup_zsh
  stow_configs
  
  # Enable Wake on LAN for network interfaces (Linux only)
  if [[ "$os" != "macos" ]]; then
    enable_wake_on_lan
  fi
  
  echo ""
  echo "==> Setup complete!"
}

# Server setup (headless Arch Linux)
server_setup() {
  echo "==> Starting server setup for Arch Linux"
  echo ""
  
  SERVER_INSTALL="true"
  export SERVER_INSTALL
  
  # Clean dangling configs first
  clean_dangling_configs
  
  # Setup filesystem
  setup_filesystem
  
  # Server-specific packages (includes Docker, Tailscale, etc.)
  setup_server_packages
  
  # Shell setup
  setup_zsh
  
  # Stow configs (will use server-specific paths)
  stow_configs
  
  # Enable Wake on LAN for network interfaces
  enable_wake_on_lan
  
  echo ""
  echo "==> Server setup complete!"
  echo ""
  echo "Services enabled (start on boot): sshd, docker, tailscaled, cronie"
  echo ""
  echo "Next steps:"
  echo "  1. Add your public key to ~/.ssh/authorized_keys"
  echo "     curl https://github.com/YOUR_USERNAME.keys >> ~/.ssh/authorized_keys"
  echo "  2. Authenticate Tailscale: sudo tailscale up"
  echo "  3. Log out and back in for docker group membership to take effect"
}

# Main
main() {
  local command="${1:-}"
  local detected_os
  detected_os=$(detect_os)
  
  case "$command" in
    server)
      if [[ "$detected_os" != "arch" ]]; then
        echo "Error: Server setup is only supported on Arch Linux"
        exit 1
      fi
      server_setup
      ;;
    clean)
      clean_dangling_configs
      ;;
    backup)
      backup_configs
      ;;
    update)
      update_packages
      ;;
    uninstall)
      uninstall_dotfiles
      ;;
    wol)
      if [[ "$detected_os" == "macos" ]]; then
        echo "Error: Wake on LAN setup is only supported on Linux"
        exit 1
      fi
      enable_wake_on_lan
      ;;
    wol-status)
      if [[ "$detected_os" == "macos" ]]; then
        echo "Error: Wake on LAN status is only supported on Linux"
        exit 1
      fi
      show_wol_status
      ;;
    help|--help|-h)
      usage
      ;;
    "")
      if [[ "$detected_os" == "unknown" ]]; then
        echo "Error: Unsupported operating system"
        exit 1
      fi
      full_setup "$detected_os"
      ;;
    *)
      echo "Unknown command: $command"
      usage
      exit 1
      ;;
  esac
}

main "$@"
