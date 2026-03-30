#!/usr/bin/env bash

# OpenClaw installation and setup script
# Installs OpenClaw personal AI assistant with daemon setup

# Install OpenClaw via npm/pnpm
install_openclaw() {
  echo "==> Installing OpenClaw"
  
  # Ensure Node.js is available via mise
  if ! command -v node &>/dev/null; then
    echo "  Node.js not found. Installing via mise..."
    if ! command -v mise &>/dev/null; then
      echo "  Error: mise not found. Please run full setup first."
      return 1
    fi
    run "mise use --global node@lts"
    # Reload mise in current session
    eval "$(mise activate bash)"
  fi
  
  # Check Node.js version (requires >= 22)
  local node_version
  node_version=$(node --version | sed 's/v//' | cut -d. -f1)
  if [[ "$node_version" -lt 22 ]]; then
    echo "  Warning: Node.js version $node_version found. OpenClaw requires Node >= 22"
    echo "  Upgrading to Node LTS..."
    run "mise use --global node@lts"
    eval "$(mise activate bash)"
  fi
  
  # Require bun for installation
  if command -v bun &>/dev/null; then
    export PATH="$HOME/.bun/bin:$PATH"
  else
    echo "  Error: bun not found. Install bun to proceed."
    return 1
  fi
  
  # Install OpenClaw globally with bun
  if command -v openclaw &>/dev/null; then
    echo "  OpenClaw already installed. Checking for updates..."
    run "bun add -g openclaw@latest"
  else
    echo "  Installing OpenClaw..."
    run "bun add -g openclaw@latest"
  fi
  
  echo "  OpenClaw installed successfully"
}

# Setup OpenClaw daemon (systemd for Linux, launchd for macOS)
setup_openclaw_daemon() {
  echo "==> Setting up OpenClaw daemon"
  
  if ! command -v openclaw &>/dev/null && [[ "$DRY_RUN" != "true" ]]; then
    echo "  Error: OpenClaw not found. Please install first."
    return 1
  fi
  
  # Run onboarding wizard with daemon installation
  echo "  Running OpenClaw onboarding wizard..."
  echo "  This will guide you through:"
  echo "    - Gateway setup"
  echo "    - Model configuration (Anthropic/OpenAI)"
  echo "    - Channel setup (WhatsApp, Telegram, Slack, Discord, etc.)"
  echo "    - Daemon installation (auto-start on boot)"
  echo ""
  
  if [[ "$DRY_RUN" != "true" ]]; then
    if [[ ! -t 0 ]]; then
      echo "  Error: OpenClaw onboarding requires an interactive TTY."
      echo "  Run manually: openclaw onboard --install-daemon"
      return 1
    fi
    if openclaw onboard --install-daemon; then
      echo "  OpenClaw daemon setup complete"
    else
      echo "  Onboarding cancelled or failed"
      return 1
    fi
  else
    echo "  [DRY RUN] Would run: openclaw onboard --install-daemon"
  fi
}

# Check OpenClaw health and configuration
check_openclaw() {
  echo "==> Checking OpenClaw status"
  
  if ! command -v openclaw &>/dev/null; then
    echo "  ❌ OpenClaw not installed"
    return 1
  fi
  
  echo "  ✓ OpenClaw installed"
  
  # Check if config exists
  if [[ -f "$HOME/.openclaw/openclaw.json" ]]; then
    echo "  ✓ Configuration found"
  else
    echo "  ⚠️  No configuration found (run 'openclaw onboard')"
  fi
  
  # Check if daemon is running (Linux systemd)
  if command -v systemctl &>/dev/null; then
    if systemctl --user is-active openclaw-gateway &>/dev/null; then
      echo "  ✓ Gateway daemon running"
    else
      echo "  ⚠️  Gateway daemon not running"
    fi
  fi
  
  # Check if daemon is running (macOS launchd)
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if launchctl list | grep -q openclaw; then
      echo "  ✓ Gateway daemon running"
    else
      echo "  ⚠️  Gateway daemon not running"
    fi
  fi
  
  # Run openclaw doctor for health check
  if [[ "$DRY_RUN" != "true" ]]; then
    echo ""
    echo "  Running 'openclaw doctor' for detailed diagnostics..."
    openclaw doctor || true
  fi
}

# Update OpenClaw to latest version
update_openclaw() {
  echo "==> Updating OpenClaw"
  
  if ! command -v openclaw &>/dev/null; then
    echo "  Error: OpenClaw not installed"
    return 1
  fi
  
  # Update via bun only
  if command -v bun &>/dev/null; then
    run "bun add -g openclaw@latest"
  else
    echo "  Error: bun not found. Install bun to proceed."
    return 1
  fi
  
  # Run doctor after update
  if [[ "$DRY_RUN" != "true" ]]; then
    openclaw doctor
  fi
  
  echo "  OpenClaw updated successfully"
}

# Uninstall OpenClaw and remove daemon
uninstall_openclaw() {
  echo "==> Uninstalling OpenClaw"
  
  # Stop daemon if running
  if command -v systemctl &>/dev/null; then
    if systemctl --user is-active openclaw-gateway &>/dev/null; then
      echo "  Stopping gateway daemon..."
      run "systemctl --user stop openclaw-gateway"
      run "systemctl --user disable openclaw-gateway"
    fi
  fi
  
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if launchctl list | grep -q openclaw; then
      echo "  Stopping gateway daemon..."
      run "launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist"
      run "rm -f ~/Library/LaunchAgents/com.openclaw.gateway.plist"
    fi
  fi
  
  # Uninstall package via bun only
  if command -v bun &>/dev/null; then
    run "bun remove -g openclaw"
  else
    echo "  Error: bun not found. Install bun to proceed."
    return 1
  fi
  
  echo "  OpenClaw uninstalled"
  echo "  NOTE: Configuration files remain in ~/.openclaw"
  echo "  To remove completely: rm -rf ~/.openclaw"
}

# Show OpenClaw usage and commands
show_openclaw_help() {
  cat <<EOF
OpenClaw Commands:

  openclaw onboard           Run setup wizard
  openclaw gateway           Start gateway manually
  openclaw doctor            Check configuration and health
  openclaw message send      Send a message
  openclaw agent             Talk to the assistant
  openclaw channels login    Login to messaging channels
  openclaw nodes             Manage device nodes

Configuration:
  ~/.openclaw/openclaw.json  Main configuration file
  ~/.openclaw/workspace      Agent workspace and skills

Daemon control (Linux):
  systemctl --user start openclaw-gateway
  systemctl --user stop openclaw-gateway
  systemctl --user status openclaw-gateway

Daemon control (macOS):
  launchctl load ~/Library/LaunchAgents/com.openclaw.gateway.plist
  launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist

Documentation:
  https://docs.openclaw.ai

EOF
}
