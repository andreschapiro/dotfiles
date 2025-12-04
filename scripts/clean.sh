#!/usr/bin/env bash

# Clean Script
# Detects and cleans dangling configs that should be managed by dotfiles

CLEANIGNORE_FILE="${DOTS_FOLDER}/.cleanignore"

# Configs that dotfiles manages - these are checked for dangling files
MANAGED_CONFIGS=(
  ".config/ghostty"
  ".config/nvim"
  ".config/tmux"
  ".config/opencode"
  ".config/git"
  ".config/fontconfig"
  ".config/starship.toml"
  ".config/new-nvim"
  ".ssh"
  ".zshrc"
  ".zshenv"
)

# Check if a path matches any pattern in .cleanignore
is_ignored() {
  local path="$1"
  local relative_path="${path#$HOME/}"
  
  if [[ ! -f "$CLEANIGNORE_FILE" ]]; then
    return 1
  fi
  
  while IFS= read -r pattern || [[ -n "$pattern" ]]; do
    # Skip empty lines and comments
    [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
    
    # Remove trailing slashes for comparison
    pattern="${pattern%/}"
    local check_path="${relative_path%/}"
    
    # Handle different pattern types
    if [[ "$pattern" == *"*"* ]]; then
      # Wildcard pattern - use bash pattern matching
      if [[ "$check_path" == $pattern ]]; then
        return 0
      fi
    elif [[ "$pattern" == /* ]]; then
      # Absolute pattern from home (starts with /)
      pattern="${pattern#/}"
      if [[ "$check_path" == "$pattern" || "$check_path" == "$pattern"/* ]]; then
        return 0
      fi
    else
      # Relative pattern - match anywhere
      if [[ "$check_path" == "$pattern" || "$check_path" == *"/$pattern" || "$check_path" == "$pattern"/* ]]; then
        return 0
      fi
    fi
  done < "$CLEANIGNORE_FILE"
  
  return 1
}

# Add a path to .cleanignore
add_to_cleanignore() {
  local path="$1"
  local relative_path="${path#$HOME/}"
  
  # Create cleanignore if it doesn't exist
  if [[ ! -f "$CLEANIGNORE_FILE" ]]; then
    echo "# Paths to ignore during clean" > "$CLEANIGNORE_FILE"
    echo "# Uses gitignore-style patterns" >> "$CLEANIGNORE_FILE"
    echo "" >> "$CLEANIGNORE_FILE"
  fi
  
  echo "$relative_path" >> "$CLEANIGNORE_FILE"
  echo "  Added '$relative_path' to .cleanignore"
}

# Prompt user for action on dangling config
prompt_action() {
  local path="$1"
  local relative_path="${path#$HOME/}"
  
  echo ""
  echo "  Found dangling config: $relative_path"
  if [[ -d "$path" ]]; then
    echo "    Type: Directory"
    echo "    Contents: $(ls -1 "$path" 2>/dev/null | wc -l | tr -d ' ') items"
  else
    echo "    Type: File"
    echo "    Size: $(ls -lh "$path" 2>/dev/null | awk '{print $5}')"
  fi
  echo ""
  echo "  Options:"
  echo "    [d] Delete - Remove this file/directory"
  echo "    [i] Ignore - Add to .cleanignore (skip in future)"
  echo "    [s] Skip   - Do nothing (will prompt again next run)"
  echo ""
  
  while true; do
    echo -n "  Choose action [d/i/s]: "
    read -r choice
    case "$choice" in
      d|D)
        echo -n "  Are you sure you want to delete '$relative_path'? [y/N]: "
        read -r confirm
        if [[ "$confirm" =~ ^[yY]$ ]]; then
          if [[ -d "$path" ]]; then
            rm -rf "$path"
          else
            rm -f "$path"
          fi
          echo "  Deleted: $relative_path"
        else
          echo "  Skipped deletion"
        fi
        return
        ;;
      i|I)
        add_to_cleanignore "$path"
        return
        ;;
      s|S)
        echo "  Skipped"
        return
        ;;
      *)
        echo "  Invalid choice. Please enter d, i, or s."
        ;;
    esac
  done
}

# Check if a config is dangling (exists but not properly symlinked to dotfiles)
is_dangling() {
  local config="$1"
  local full_path="${HOME}/${config}"
  local dotfiles_path="${DOTS_FOLDER}/${config}"
  
  # If path doesn't exist, it's not dangling
  [[ ! -e "$full_path" ]] && return 1
  
  # If it's a symlink pointing to our dotfiles, it's not dangling
  if [[ -L "$full_path" ]]; then
    local link_target
    link_target=$(readlink "$full_path")
    if [[ "$link_target" == *"dotfiles"* || "$link_target" == "${DOTS_FOLDER}"* ]]; then
      return 1
    fi
  fi
  
  # If we have a corresponding file in dotfiles, then this is dangling
  if [[ -e "$dotfiles_path" ]]; then
    return 0
  fi
  
  # No corresponding dotfiles entry, so not our concern
  return 1
}

# Main clean function
clean_dangling_configs() {
  echo "==> Checking for dangling configurations"
  
  local found_dangling=false
  
  for config in "${MANAGED_CONFIGS[@]}"; do
    local full_path="${HOME}/${config}"
    
    # Skip if ignored
    if is_ignored "$full_path"; then
      continue
    fi
    
    # Check if dangling
    if is_dangling "$config"; then
      found_dangling=true
      prompt_action "$full_path"
    fi
  done
  
  if [[ "$found_dangling" == "false" ]]; then
    echo "  No dangling configurations found"
  fi
  
  echo ""
  echo "  Clean check complete"
}

# Run clean in non-interactive mode (just report)
clean_report_only() {
  echo "==> Checking for dangling configurations (report only)"
  
  local found_dangling=false
  
  for config in "${MANAGED_CONFIGS[@]}"; do
    local full_path="${HOME}/${config}"
    
    # Skip if ignored
    if is_ignored "$full_path"; then
      continue
    fi
    
    # Check if dangling
    if is_dangling "$config"; then
      found_dangling=true
      local relative_path="${full_path#$HOME/}"
      echo "  DANGLING: $relative_path"
    fi
  done
  
  if [[ "$found_dangling" == "false" ]]; then
    echo "  No dangling configurations found"
  fi
}
