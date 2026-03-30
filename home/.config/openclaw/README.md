# OpenClaw Configuration

OpenClaw stores its main configuration at `~/.openclaw/openclaw.json` (not managed by stow).

This directory contains example configurations for reference.

## Setup

1. Install OpenClaw:
   ```bash
   cd ~/dotfiles
   ./openclaw-setup.sh install
   ```

2. The installer will run the onboarding wizard which creates `~/.openclaw/openclaw.json`

3. Optionally copy the example config as a starting point:
   ```bash
   cp ~/.config/openclaw/openclaw.json.example ~/.openclaw/openclaw.json
   ```

## Configuration Files

- `openclaw.json.example` - Minimal example configuration
- Main config location: `~/.openclaw/openclaw.json` (created by onboarding)
- Workspace: `~/.openclaw/workspace/` (agent files, skills)

## Quick Start

After installation:

```bash
# Check status
openclaw doctor

# Start gateway (daemon should auto-start)
systemctl --user status openclaw-gateway  # Linux
launchctl list | grep openclaw             # macOS

# Send a test message
openclaw message send --to +1234567890 --message "Hello"

# Talk to the agent
openclaw agent --message "What can you do?"
```

## Documentation

- Main docs: https://docs.openclaw.ai
- Getting started: https://docs.openclaw.ai/start/getting-started
- Configuration: https://docs.openclaw.ai/gateway/configuration
- Channels: https://docs.openclaw.ai/channels
