# dotfiles

Personal dotfiles for macOS and Arch Linux (Omarchy).

## Quick Start

```bash
# Clone the repo
git clone https://github.com/andychapman/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup
./setup.sh
```

## Commands

| Command | Description |
|---------|-------------|
| `./setup.sh` | Full setup: clean, packages, fonts, shell, stow |
| `./setup.sh clean` | Check for and clean dangling configs |
| `./setup.sh backup` | Backup current configurations |
| `./setup.sh update` | Update packages (brew/pacman, mise) |
| `./setup.sh uninstall` | Remove symlinks |

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
│   │   ├── git/             # Git config
│   │   ├── fontconfig/      # Font config (Linux only)
│   │   ├── ssh/             # SSH config
│   │   └── starship.toml    # Starship prompt
│   ├── .zshrc               # Zsh configuration
│   ├── .zshenv              # Zsh environment
│   ├── .bashrc              # Bash configuration
│   ├── .vimrc               # Vim configuration
│   └── .p10k.zsh            # Powerlevel10k (legacy)
├── scripts/                 # Setup scripts (not stowed)
│   ├── packages.sh          # Package installation
│   ├── fonts.sh             # Font installation
│   ├── shell.sh             # Zsh/Oh My Zsh setup
│   ├── stow.sh              # Symlink management
│   ├── clean.sh             # Dangling config detection
│   └── maintenance.sh       # Backup/update utilities
├── fonts/                   # Font README (not stowed)
├── dotfiles-data/           # Private repo with fonts (not stowed)
├── setup.sh                 # Main setup script
├── .cleanignore             # Paths to ignore during clean
└── README.md
```

## How Stow Works

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management.

**Only items in `home/` are stowed.** The `home/` directory mirrors your home directory structure. When you run `./setup.sh`, stow creates symlinks:

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

## Fonts

Fonts are stored in a separate private repository (`dotfiles-data`) due to licensing. The setup script will attempt to clone it if you have SSH access.

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
