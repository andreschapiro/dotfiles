#!/usr/bin/env bash

setup_filesystem() {
  if [ -d "$HOME/Projects" ]; then
    echo "The ~/Projects directory exists"
  else
    if run "mkdir $HOME/Projects"; then
      echo "The ~/Projects directory has been created"
    else
      echo "Failed to create ~/Projects directory" >&2
      exit 1
    fi
  fi
  if [ -d "$HOME/.tmux" ]; then
    echo "The ~/.tmux directory exists"
  else
    if run "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"; then
      echo "Cloned TPM repo"
    else
      echo "Failed to clone the TPM repo" >&2
      exit 1
    fi
  fi
}
