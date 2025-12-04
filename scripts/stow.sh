#!/usr/bin/env bash

# Stow Script
# Uses GNU stow to create symlinks for dotfiles
# Only paths listed in MANAGED_PATHS will be stowed

# Paths that stow will manage
# These must exist in home/ directory to be stowed
MANAGED_PATHS=(
  ".config/ghostty"
  ".config/nvim"
  ".config/new-nvim"
  ".config/tmux"
  ".config/opencode"
  ".config/git"
  ".config/fontconfig"
  ".config/starship.toml"
  ".zshrc"
  ".zshenv"
  ".bashrc"
  ".vimrc"
  ".p10k.zsh"
)

# Backup existing real files/directories (not symlinks) before stowing
backup_existing_configs() {
  local backup_timestamp
  backup_timestamp=$(date +%s)

  for path in "${MANAGED_PATHS[@]}"; do
    local full_path="${HOME}/${path}"

    # Skip if doesn't exist or is already a symlink
    [[ ! -e "$full_path" ]] && continue
    [[ -L "$full_path" ]] && continue

    echo "  Backing up: $full_path"
    run "mv \"$full_path\" \"${full_path}.backup.${backup_timestamp}\""
  done
}

# Remove existing symlinks so stow can recreate them
remove_existing_symlinks() {
  for path in "${MANAGED_PATHS[@]}"; do
    local full_path="${HOME}/${path}"

    if [[ -L "$full_path" ]]; then
      echo "  Removing existing symlink: $full_path"
      run "rm \"$full_path\""
    fi
  done
}

stow_configs() {
  echo "==> Stowing configuration files"

  # Ensure ~/.config exists
  run "mkdir -p \"${HOME}/.config\""

  # Backup real files/directories
  backup_existing_configs

  # Remove existing symlinks so stow can recreate them properly
  remove_existing_symlinks

  # Stow the home package (excludes .ssh to preserve keys)
  # --restow (-R) will restow (useful for updates)
  # --target specifies where symlinks are created
  # --ignore='.ssh' prevents stow from touching ~/.ssh directory
  echo "  Running stow..."
  run "cd ${DOTS_FOLDER} && stow -R --target=${HOME} --ignore='.ssh' home"

  # Manually symlink SSH config (preserves existing keys in ~/.ssh)
  echo "  Linking SSH config..."
  run "mkdir -p \"${HOME}/.ssh\""
  run "chmod 700 \"${HOME}/.ssh\""
  if [[ -L "${HOME}/.ssh/config" ]]; then
    run "rm \"${HOME}/.ssh/config\""
  elif [[ -f "${HOME}/.ssh/config" && ! -L "${HOME}/.ssh/config" ]]; then
    local backup_timestamp
    backup_timestamp=$(date +%s)
    run "mv \"${HOME}/.ssh/config\" \"${HOME}/.ssh/config.backup.${backup_timestamp}\""
  fi
  run "ln -sf \"${DOTS_FOLDER}/home/.ssh/config\" \"${HOME}/.ssh/config\""

  # Refresh font cache
  if command -v fc-cache &>/dev/null; then
    echo "  Refreshing font cache..."
    fc-cache -f 2>/dev/null
  fi

  echo "  Stow complete"
}
