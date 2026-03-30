#!/usr/bin/env bash

set -euo pipefail

DOTS_FOLDER="${HOME}/dotfiles"
DRY_RUN="${DRY_RUN:-false}"

# Source openclaw functions
source "${DOTS_FOLDER}/scripts/openclaw.sh"

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
  echo "Usage: ./openclaw-setup.sh [command]"
  echo ""
  echo "Commands:"
  echo "  install     Install OpenClaw and setup daemon"
  echo "  status      Check OpenClaw installation and health"
  echo "  update      Update OpenClaw to latest version"
  echo "  uninstall   Remove OpenClaw and daemon"
  echo "  help        Show OpenClaw usage and commands"
  echo ""
  echo "Environment variables:"
  echo "  DRY_RUN=true  Show commands without executing"
  echo ""
  echo "Examples:"
  echo "  ./openclaw-setup.sh install     # Full installation"
  echo "  ./openclaw-setup.sh status      # Check status"
  echo "  ./openclaw-setup.sh update      # Update to latest"
}

# Main
main() {
  local command="${1:-}"
  
  case "$command" in
    install)
      echo "==> OpenClaw Installation"
      echo ""
      install_openclaw
      echo ""
      setup_openclaw_daemon
      echo ""
      echo "==> Installation complete!"
      echo ""
      show_openclaw_help
      ;;
    status)
      check_openclaw
      ;;
    update)
      update_openclaw
      ;;
    uninstall)
      echo "This will uninstall OpenClaw and remove the daemon."
      echo "Configuration files in ~/.openclaw will be preserved."
      echo ""
      read -p "Continue? [y/N] " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        uninstall_openclaw
      else
        echo "Cancelled."
      fi
      ;;
    help|--help|-h)
      show_openclaw_help
      ;;
    "")
      usage
      ;;
    *)
      echo "Unknown command: $command"
      usage
      exit 1
      ;;
  esac
}

main "$@"
