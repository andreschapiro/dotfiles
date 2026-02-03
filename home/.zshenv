export EDITOR=nvim

# 1Password SSH Agent
# Only use 1Password socket if SSH agent forwarding isn't already active
if [[ -z "$SSH_AUTH_SOCK" ]] || [[ ! -S "$SSH_AUTH_SOCK" ]]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi
