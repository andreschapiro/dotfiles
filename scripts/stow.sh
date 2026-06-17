#!/usr/bin/env bash

# Stow Script
# Uses GNU stow to create symlinks for dotfiles
# Only paths listed in MANAGED_PATHS will be stowed

# Paths that stow will manage (desktop/laptop)
# These must exist in home/ directory to be stowed
MANAGED_PATHS=(
  ".config/ghostty"
  ".config/nvim"
  ".config/new-nvim"
  ".config/tmux"
  ".config/opencode"
  ".config/pnpm"
  ".config/git"
  ".config/fontconfig"
  ".config/starship.toml"
  ".npmrc"
  ".bunfig.toml"
  ".zshrc"
  ".zshenv"
  ".bashrc"
  ".vimrc"
  ".p10k.zsh"
)

# Paths for server install (no GUI configs)
MANAGED_PATHS_SERVER=(
  ".config/nvim"
  ".config/tmux"
  ".config/opencode"
  ".config/systemd/user/opencode-web.service"
  ".config/pnpm"
  ".config/git"
  ".config/starship.toml"
  ".npmrc"
  ".bunfig.toml"
  ".zshrc"
  ".zshenv"
  ".bashrc"
  ".vimrc"
  ".p10k.zsh"
)

# Get the appropriate managed paths based on install type
get_managed_paths() {
  if [[ "${SERVER_INSTALL:-false}" == "true" ]]; then
    echo "${MANAGED_PATHS_SERVER[@]}"
  else
    echo "${MANAGED_PATHS[@]}"
  fi
}

# Get the home directory to stow from
get_stow_source() {
  if [[ "${SERVER_INSTALL:-false}" == "true" ]]; then
    echo "home-server"
  else
    echo "home"
  fi
}

# Backup existing real files/directories (not symlinks) before stowing
backup_existing_configs() {
  local backup_timestamp
  backup_timestamp=$(date +%s)
  local paths
  read -ra paths <<< "$(get_managed_paths)"

  for path in "${paths[@]}"; do
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
  local paths
  read -ra paths <<< "$(get_managed_paths)"

  for path in "${paths[@]}"; do
    local full_path="${HOME}/${path}"

    if [[ -L "$full_path" ]]; then
      echo "  Removing existing symlink: $full_path"
      run "rm \"$full_path\""
    fi
  done
}

stow_configs() {
  echo "==> Stowing configuration files"
  
  local stow_source
  stow_source=$(get_stow_source)

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
  echo "  Running stow from ${stow_source}..."
  run "cd ${DOTS_FOLDER} && stow -R --target=${HOME} --ignore='.ssh' ${stow_source}"
  
  # For server installs, also stow shared configs from home/ that aren't in home-server/
  if [[ "${SERVER_INSTALL:-false}" == "true" ]]; then
    echo "  Stowing shared configs from home/..."
    # Stow specific shared directories that server needs but aren't duplicated
    for shared_path in ".config/nvim" ".config/tmux" ".config/opencode" ".config/pnpm" ".config/git" ".config/starship.toml" ".npmrc" ".bunfig.toml" ".zshrc" ".zshenv" ".bashrc" ".vimrc" ".p10k.zsh"; do
      if [[ -e "${DOTS_FOLDER}/home/${shared_path}" ]] && [[ ! -e "${DOTS_FOLDER}/home-server/${shared_path}" ]]; then
        # Only stow if not already in home-server
        local target="${HOME}/${shared_path}"
        local source="${DOTS_FOLDER}/home/${shared_path}"
        if [[ ! -L "$target" ]]; then
          run "ln -sf \"$source\" \"$target\""
        fi
      fi
    done
  fi

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
  run "ln -sf \"${DOTS_FOLDER}/${stow_source}/.ssh/config\" \"${HOME}/.ssh/config\""

  # Refresh font cache (skip on server)
  if [[ "${SERVER_INSTALL:-false}" != "true" ]] && command -v fc-cache &>/dev/null; then
    echo "  Refreshing font cache..."
    fc-cache -f 2>/dev/null
  fi

  echo "  Stow complete"
}
