#!/usr/bin/env bash

set -euo pipefail

DOTS_FOLDER="${HOME}/dotfiles"
DRY_RUN="${DRY_RUN:-false}"

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
  echo "  clean       Check for and clean dangling configs"
  echo "  backup      Backup current configurations"
  echo "  update      Update packages (brew/pacman, mise)"
  echo "  uninstall   Remove symlinks created by stow"
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
  
  echo ""
  echo "==> Setup complete!"
}

# Main
main() {
  local command="${1:-}"
  local detected_os
  detected_os=$(detect_os)
  
  case "$command" in
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
