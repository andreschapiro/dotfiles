# OpenClaw Setup Guide

OpenClaw is a personal AI assistant that runs on your own devices and connects to messaging platforms like WhatsApp, Telegram, Slack, Discord, Signal, iMessage, and more.

## Installation

OpenClaw has its own standalone setup script to keep it separate from your main dotfiles setup.

```bash
cd ~/dotfiles
./openclaw-setup.sh install
```

This will:
1. Install Node.js LTS via mise (if needed)
2. Install OpenClaw globally via pnpm
3. Run the onboarding wizard to configure:
   - Gateway setup
   - Model configuration (Anthropic Claude or OpenAI)
   - Channel setup (messaging platforms)
   - Daemon installation (auto-start on boot)

## Requirements

- Node.js ≥ 22 (installed automatically via mise)
- Linux (systemd) or macOS (launchd) for daemon support

## Commands

```bash
# Check installation status
./openclaw-setup.sh status

# Update to latest version
./openclaw-setup.sh update

# Uninstall (keeps config)
./openclaw-setup.sh uninstall

# Show help and documentation
./openclaw-setup.sh help

# Dry run (preview without executing)
DRY_RUN=true ./openclaw-setup.sh install
```

## Configuration

OpenClaw stores its configuration separately from your dotfiles:

- **Main config**: `~/.openclaw/openclaw.json`
- **Workspace**: `~/.openclaw/workspace/`
- **Example config**: `~/.config/openclaw/openclaw.json.example`

The onboarding wizard creates the main config. You can also manually edit it.

### Minimal Configuration

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-5"
  },
  "gateway": {
    "port": 18789
  }
}
```

## Using OpenClaw

After installation, the gateway daemon runs automatically on boot.

```bash
# Check daemon status
systemctl --user status openclaw-gateway  # Linux
launchctl list | grep openclaw             # macOS

# Run health check
openclaw doctor

# Send a message
openclaw message send --to +1234567890 --message "Hello"

# Talk to the assistant
openclaw agent --message "What can you do?"

# Login to messaging channels
openclaw channels login
```

## Channels

OpenClaw can connect to:
- WhatsApp (via Baileys)
- Telegram (bot API)
- Slack (Bolt SDK)
- Discord (discord.js)
- Google Chat
- Signal (via signal-cli)
- iMessage (macOS only)
- Microsoft Teams
- And more...

Each channel requires specific setup (bot tokens, pairing, etc.). The onboarding wizard guides you through this.

## Security

By default, OpenClaw uses a pairing flow for unknown senders. To approve someone:

```bash
openclaw pairing approve <channel> <code>
```

For more open access, you can configure `dmPolicy: "open"` in your config.

## Documentation

- Main docs: https://docs.openclaw.ai
- Getting started: https://docs.openclaw.ai/start/getting-started
- Configuration reference: https://docs.openclaw.ai/gateway/configuration
- Channels: https://docs.openclaw.ai/channels
- Security: https://docs.openclaw.ai/gateway/security

## Why Separate from Main Dotfiles?

OpenClaw is kept separate because:
1. It has its own update cycle independent of your dotfiles
2. It requires Node.js ≥ 22 which may differ from other tools
3. The configuration is user-specific and stored in `~/.openclaw/`
4. You may want to install/update OpenClaw without touching other configs

## Troubleshooting

```bash
# Run diagnostics
openclaw doctor

# Check logs
journalctl --user -u openclaw-gateway  # Linux systemd

# Restart daemon
systemctl --user restart openclaw-gateway  # Linux

# Manual start (for debugging)
openclaw gateway --port 18789 --verbose
```
