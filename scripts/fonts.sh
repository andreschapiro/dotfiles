#!/usr/bin/env bash

# Font installation script
# Clones dotfiles-data (private repo with fonts) if not present, then installs fonts

# Private repo containing fonts
DOTFILES_DATA_REPO="git@github.com:andreschapiro/dotfiles-data.git"
DOTFILES_DATA_DIR="${DOTS_FOLDER}/dotfiles-data"

# Clone dotfiles-data if fonts are missing
clone_dotfiles_data() {
  local fonts_dir="${DOTFILES_DATA_DIR}/fonts"

  # Check if fonts already exist in dotfiles-data
  if [[ -d "$fonts_dir" ]] && [[ -n "$(ls -A "$fonts_dir" 2>/dev/null)" ]]; then
    echo "  dotfiles-data fonts already present"
    return 0
  fi

  # Check if we have SSH access (for private repo)
  if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "  Warning: No GitHub SSH access, skipping private fonts"
    echo "  Fonts will need to be manually installed to ~/dotfiles/dotfiles-data/fonts/"
    return 1
  fi

  echo "  Cloning dotfiles-data (private fonts repo)..."
  if [[ -d "$DOTFILES_DATA_DIR" ]]; then
    # Directory exists but fonts missing - try to pull
    run "cd ${DOTFILES_DATA_DIR} && git pull"
  else
    # Fresh clone
    run "git clone ${DOTFILES_DATA_REPO} ${DOTFILES_DATA_DIR}"
  fi

  return 0
}

# Get the source fonts directory (prefers dotfiles-data, falls back to fonts/)
get_fonts_source() {
  local data_fonts="${DOTFILES_DATA_DIR}/fonts"
  local fallback_fonts="${DOTS_FOLDER}/fonts"

  if [[ -d "$data_fonts" ]] && [[ -n "$(ls -A "$data_fonts" 2>/dev/null)" ]]; then
    echo "$data_fonts"
  elif [[ -d "$fallback_fonts" ]] && [[ -n "$(ls -A "$fallback_fonts" 2>/dev/null)" ]]; then
    echo "$fallback_fonts"
  else
    echo ""
  fi
}

# Install fonts to destination directory
install_fonts() {
  local dest_folder="$1"
  local fonts_folder
  fonts_folder=$(get_fonts_source)

  if [[ -z "$fonts_folder" ]]; then
    echo "  Warning: No fonts found to install"
    return 1
  fi

  echo "  Installing fonts from $fonts_folder"
  mkdir -p "$dest_folder"

  local installed=0
  local skipped=0

  for file in "$fonts_folder"/*.ttf "$fonts_folder"/*.otf; do
    [[ -f "$file" ]] || continue

    local filename
    filename=$(basename "$file")

    # Skip README files
    [[ "$filename" == "README.md" ]] && continue

    if [[ ! -e "$dest_folder/$filename" ]]; then
      cp "$file" "$dest_folder/$filename"
      ((installed++))
    else
      ((skipped++))
    fi
  done

  echo "  Installed: $installed fonts, Skipped: $skipped (already exist)"

  # Refresh font cache
  if command -v fc-cache &>/dev/null; then
    echo "  Refreshing font cache..."
    fc-cache -f "$dest_folder"
  fi
}

setup_arch_fonts() {
  echo "==> Installing fonts for Linux"

  # Try to clone dotfiles-data for fonts
  clone_dotfiles_data

  local dest_folder="$HOME/.local/share/fonts"
  install_fonts "$dest_folder"
}

setup_mac_fonts() {
  echo "==> Installing fonts for macOS"

  # Try to clone dotfiles-data for fonts
  clone_dotfiles_data

  local dest_folder="$HOME/Library/Fonts"
  install_fonts "$dest_folder"
}
