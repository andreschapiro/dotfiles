#!/usr/bin/env bash
# sshd-config.sh - Deploy SSH server configuration
# Part of dotfiles: Configures sshd to use key-based authentication only

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
SSHD_CONFIG_SOURCE="$DOTFILES_DIR/home-server/etc/ssh/sshd_config.d/10-key-only.conf"
SSHD_CONFIG_DEST="/etc/ssh/sshd_config.d/10-key-only.conf"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on a system that supports sshd_config.d
check_sshd_support() {
  if ! grep -q "^Include /etc/ssh/sshd_config.d/\*.conf" /etc/ssh/sshd_config; then
    log_error "Your sshd_config doesn't include /etc/ssh/sshd_config.d/*.conf"
    log_info "Add this line to /etc/ssh/sshd_config:"
    echo "  Include /etc/ssh/sshd_config.d/*.conf"
    return 1
  fi
  return 0
}

# Verify SSH key is present before disabling password auth
check_ssh_keys() {
  if [ ! -f "$HOME/.ssh/authorized_keys" ] || [ ! -s "$HOME/.ssh/authorized_keys" ]; then
    log_warning "No SSH keys found in ~/.ssh/authorized_keys"
    log_warning "You should add your public key before disabling password authentication!"
    echo -e "\n${YELLOW}Do you want to continue anyway? (y/N)${NC} "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_info "Aborting. Add your SSH key first with:"
      echo "  mkdir -p ~/.ssh"
      echo "  echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys"
      echo "  chmod 600 ~/.ssh/authorized_keys"
      exit 1
    fi
  else
    log_success "Found SSH authorized_keys file"
  fi
}

# Deploy configuration
deploy_config() {
  log_info "Deploying SSH server configuration..."
  
  # Create backup if file exists
  if [ -f "$SSHD_CONFIG_DEST" ]; then
    local backup="$SSHD_CONFIG_DEST.backup.$(date +%s)"
    log_info "Backing up existing config to $backup"
    sudo cp "$SSHD_CONFIG_DEST" "$backup"
  fi
  
  # Copy configuration
  log_info "Copying configuration to $SSHD_CONFIG_DEST"
  sudo cp "$SSHD_CONFIG_SOURCE" "$SSHD_CONFIG_DEST"
  sudo chmod 644 "$SSHD_CONFIG_DEST"
  
  log_success "Configuration deployed"
}

# Test configuration
test_config() {
  log_info "Testing sshd configuration..."
  if sudo sshd -t; then
    log_success "sshd configuration is valid"
    return 0
  else
    log_error "sshd configuration test failed!"
    return 1
  fi
}

# Restart sshd
restart_sshd() {
  log_warning "The SSH server needs to be restarted for changes to take effect."
  echo -e "${YELLOW}Do you want to restart sshd now? (y/N)${NC} "
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    log_info "Restarting sshd..."
    if sudo systemctl restart sshd 2>/dev/null || sudo systemctl restart ssh 2>/dev/null; then
      log_success "sshd restarted successfully"
    else
      log_error "Failed to restart sshd. Restart it manually with:"
      echo "  sudo systemctl restart sshd"
      echo "  or"
      echo "  sudo systemctl restart ssh"
    fi
  else
    log_info "Skipping restart. Remember to restart sshd later with:"
    echo "  sudo systemctl restart sshd"
  fi
}

main() {
  echo -e "${BLUE}=== SSH Server Configuration Deployment ===${NC}\n"
  
  log_warning "This will configure SSH to ONLY accept key-based authentication."
  log_warning "Password authentication will be disabled."
  echo ""
  
  # Pre-flight checks
  check_ssh_keys
  check_sshd_support || exit 1
  
  # Deploy and test
  deploy_config
  
  if test_config; then
    restart_sshd
    echo ""
    log_success "SSH server configuration complete!"
    log_info "Password authentication is now disabled."
    log_info "Only SSH key authentication is allowed."
  else
    log_error "Configuration test failed. Rolling back..."
    if [ -f "$SSHD_CONFIG_DEST.backup."* ]; then
      sudo mv "$SSHD_CONFIG_DEST.backup."* "$SSHD_CONFIG_DEST"
      log_info "Rolled back to previous configuration"
    fi
    exit 1
  fi
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
