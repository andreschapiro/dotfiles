#!/usr/bin/env bash

# Maintenance Script
# Provides backup and update functionality for dotfiles

backup_configs() {
  echo "==> Backing up configurations"
  
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_dir="${HOME}/dotfiles_backup_${timestamp}"
  
  mkdir -p "$backup_dir"
  
  # Configs to backup
  local configs=(
    .zshrc
    .zshenv
    .bashrc
    .vimrc
    .config/nvim
    .config/dev
    .config/ghostty
    .config/tmux
    .config/opencode
    .config/pnpm
    .config/git
    .config/starship.toml
    .npmrc
    .bunfig.toml
    .local/bin/dev
  )
  
  for config in "${configs[@]}"; do
    local source="${HOME}/${config}"
    if [[ -e "$source" ]]; then
      # Preserve directory structure in backup
      local dest_dir="$backup_dir/$(dirname "$config")"
      mkdir -p "$dest_dir"
      cp -r "$source" "$dest_dir/"
      echo "  Backed up: $config"
    fi
  done
  
  echo "  Backup created at $backup_dir"
}

update_dotfiles() {
  echo "==> Updating dotfiles"
  
  # Pull latest from main dotfiles repo
  echo "  Pulling latest dotfiles..."
  if [[ -d "${DOTS_FOLDER}/.git" ]]; then
    run "cd ${DOTS_FOLDER} && git pull"
  else
    echo "  Warning: dotfiles is not a git repo"
  fi
  
  # Pull latest from dotfiles-data if it exists
  local data_dir="${DOTS_FOLDER}/dotfiles-data"
  if [[ -d "${data_dir}/.git" ]]; then
    echo "  Pulling latest dotfiles-data..."
    run "cd ${data_dir} && git pull"
  fi
  
  # Re-run stow to update symlinks
  echo "  Re-stowing configs..."
  stow_configs
  
  echo "  Update complete"
}

update_packages() {
  echo "==> Updating packages"
  
  case "$(uname -s)" in
    Darwin*)
      echo "  Updating Homebrew packages..."
      run "brew update && brew upgrade"
      run "brew cleanup"
      run "brew autoremove"
      ;;
    Linux*)
      if command -v pacman &>/dev/null; then
        echo "  Updating pacman packages..."
        run "sudo pacman -Syu --noconfirm"
        # Clean package cache
        run "sudo pacman -Sc --noconfirm"
      elif command -v apt &>/dev/null; then
        echo "  Updating apt packages..."
        run "sudo apt update && sudo apt upgrade -y"
        run "sudo apt autoremove -y && sudo apt autoclean"
      fi
      ;;
  esac
  
  # Update mise if installed
  if command -v mise &>/dev/null; then
    echo "  Updating mise and managed runtimes..."
    run "mise self-update"
    run "mise upgrade"
  fi

  # Update Zsh plugins
  local plugin_dir="${HOME}/.zsh/plugins"
  if [[ -d "$plugin_dir" ]]; then
    for plugin in "$plugin_dir"/*; do
      if [[ -d "$plugin/.git" ]]; then
        echo "  Updating Zsh plugin: $(basename "$plugin")"
        run "cd $plugin && git pull"
      fi
    done
  fi
  
  echo "  Package update complete"
}

uninstall_dotfiles() {
  echo "==> Uninstalling dotfiles (removing symlinks)"
  
  # List of symlinks to remove
  local symlinks=(
    "${HOME}/.config/ghostty"
    "${HOME}/.config/dev"
    "${HOME}/.config/nvim"
    "${HOME}/.config/tmux"
    "${HOME}/.config/opencode"
    "${HOME}/.config/pnpm"
    "${HOME}/.config/git"
    "${HOME}/.config/fontconfig"
    "${HOME}/.config/starship.toml"
    "${HOME}/.npmrc"
    "${HOME}/.bunfig.toml"
    "${HOME}/.ssh"
    "${HOME}/.zshrc"
    "${HOME}/.zshenv"
    "${HOME}/.local/bin/dev"
  )
  
  for link in "${symlinks[@]}"; do
    if [[ -L "$link" ]]; then
      echo "  Removing symlink: $link"
      run "rm $link"
    fi
  done
  
  echo "  Uninstall complete. Original files (if backed up) can be restored."
}
