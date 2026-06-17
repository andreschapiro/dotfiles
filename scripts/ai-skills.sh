#!/usr/bin/env bash

# Public, tool-agnostic AI skills library.
# The skills CLI installs it into each agent's native global skills directory.

AI_SKILLS_DIR="${AI_SKILLS_DIR:-${HOME}/ai-skills}"
AI_SKILLS_REPO="${AI_SKILLS_REPO:-https://github.com/andreschapiro/ai-skills.git}"
AI_SKILLS_AGENTS="${AI_SKILLS_AGENTS:-opencode}"

setup_ai_skills() {
  echo "==> Setting up AI skills"

  sync_ai_skills_repo
  install_ai_skills
}

sync_ai_skills_repo() {
  if [[ -d "${AI_SKILLS_DIR}/.git" ]]; then
    if git -C "${AI_SKILLS_DIR}" remote get-url origin &>/dev/null; then
      echo "  Updating ${AI_SKILLS_DIR}..."
      run "git -C \"${AI_SKILLS_DIR}\" pull --ff-only"
    else
      echo "  ${AI_SKILLS_DIR} exists without an origin remote; skipping update"
    fi
    return
  fi

  if [[ -e "${AI_SKILLS_DIR}" ]]; then
    echo "Error: ${AI_SKILLS_DIR} exists but is not a git repository" >&2
    echo "Move it aside or set AI_SKILLS_DIR to a different path." >&2
    exit 1
  fi

  run "git clone \"${AI_SKILLS_REPO}\" \"${AI_SKILLS_DIR}\""
}

install_ai_skills() {
  local agent_args=""

  for agent in ${AI_SKILLS_AGENTS}; do
    agent_args="${agent_args} -a \"${agent}\""
  done

  run "npx -y skills add \"${AI_SKILLS_DIR}\" -g --skill '*'${agent_args} -y"
}
