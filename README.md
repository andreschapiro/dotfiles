# dotfiles

Personal dotfiles for macOS and Arch Linux (Omarchy).

## Quick Start

```bash
# Clone the repo
git clone https://github.com/andreschapiro/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup
./setup.sh
```

## Commands

| Command                | Description                                     |
| ---------------------- | ----------------------------------------------- |
| `./setup.sh`           | Full setup: clean, packages, fonts, shell, stow |
| `./setup.sh clean`     | Check for and clean dangling configs            |
| `./setup.sh backup`    | Backup current configurations                   |
| `./setup.sh update`    | Update packages (brew/pacman, mise)             |
| `./setup.sh uninstall` | Remove symlinks                                 |

### AI Skills

The setup script clones or updates a public, tool-agnostic skills repository at `~/ai-skills`, then installs its skills with `npx skills add`:

```bash
AI_SKILLS_REPO=https://github.com/andreschapiro/ai-skills.git ./setup.sh
```

By default, skills are installed globally for OpenCode. To install into additional supported agents, set `AI_SKILLS_AGENTS` to a space-separated list:

```bash
AI_SKILLS_AGENTS="opencode claude-code codex" ./setup.sh
```

The source repository stays separate so other AI tools can consume the same files.

### Dry Run

Preview what will happen without making changes:

```bash
DRY_RUN=true ./setup.sh
```

## What's Included

- **Shell**: Zsh with Oh My Zsh, Starship prompt, syntax highlighting, autosuggestions
- **Editor**: Neovim with lazy.nvim (self-bootstrapping)
- **Terminal**: Ghostty configuration
- **Multiplexer**: tmux configuration
- **Tools**: OpenCode, git, starship, fontconfig (Linux)

## Repository Structure

```
~/dotfiles/
├── home/                    # Stowed to ~ (symlinked configs)
│   ├── .config/
│   │   ├── ghostty/         # Terminal emulator
│   │   ├── nvim/            # Neovim (LazyVim)
│   │   ├── new-nvim/        # Neovim (custom config)
│   │   ├── tmux/            # tmux
│   │   ├── opencode/        # OpenCode AI
│   │   ├── pnpm/            # pnpm package manager config
│   │   ├── git/             # Global Git ignore rules
│   │   ├── fontconfig/      # Font config (Linux only)
│   │   └── starship.toml    # Starship prompt
│   ├── .zshrc               # Zsh configuration
│   ├── .zshenv              # Zsh environment
│   ├── .bunfig.toml         # Bun package manager config
│   ├── .bashrc              # Bash configuration
│   ├── .vimrc               # Vim configuration
│   └── .p10k.zsh            # Powerlevel10k (legacy)
├── scripts/                 # Setup scripts (not stowed)
│   ├── ai-skills.sh         # Public AI skills repo setup
│   ├── packages.sh          # Package installation
│   ├── fonts.sh             # Font installation
│   ├── shell.sh             # Zsh/Oh My Zsh setup
│   ├── stow.sh              # Symlink management
│   ├── clean.sh             # Dangling config detection
│   └── maintenance.sh       # Backup/update utilities
├── fonts/                   # Font README (not stowed)
├── dotfiles-data/           # Private fonts and machine-specific overlay
├── setup.sh                 # Main setup script
├── .cleanignore             # Paths to ignore during clean
└── README.md
```

## How Stow Works

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management.

The public `home/` directory mirrors your home directory structure. When you
run `./setup.sh`, it is stowed first and the matching private overlay is stowed
afterward:

```
~/dotfiles/home/.zshrc  →  ~/.zshrc
~/dotfiles/home/.config/nvim  →  ~/.config/nvim
```

### Adding a New Config

1. Add the config to `home/` mirroring where it should appear in `~`
2. Add the path to `MANAGED_PATHS` in `scripts/stow.sh`
3. Run `./setup.sh` to create the symlink

### MANAGED_PATHS

The `MANAGED_PATHS` array in `scripts/stow.sh` defines which configs are managed:

```bash
MANAGED_PATHS=(
  ".config/ghostty"
  ".config/nvim"
  ".config/tmux"
  ".zshrc"
  # ... etc
)
```

This is used for:

- Backing up existing configs before stowing
- Removing old symlinks before re-stowing
- Documentation of what's managed

## Private Overlay

Machine-specific files are stored in the private `dotfiles-data` repository.
Setup clones it when SSH access is available and stows its `home/` or
`home-server/` package after the public configuration. This keeps SSH hosts,
Git identity, local shell settings, server services, and licensed fonts out of
the public repository.

## Fonts

Fonts are stored in `dotfiles-data` due to licensing. The setup script will attempt to clone it if you have SSH access.

To manually install fonts, place `.otf` or `.ttf` files in:

- **macOS**: `~/Library/Fonts/`
- **Linux**: `~/.local/share/fonts/`

## Updating

```bash
cd ~/dotfiles
git pull
./setup.sh
```

## Cleaning

The `.cleanignore` file uses gitignore-style patterns to specify paths that should be ignored during the clean check.

## Requirements

- macOS or Arch Linux
- Git
- curl (for installing Homebrew, mise, etc.)
