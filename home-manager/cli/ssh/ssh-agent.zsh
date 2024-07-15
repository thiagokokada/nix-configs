_start_agent() {
  # Get the filename to store/lookup the environment from
  local -r ssh_env_cache="$HOME/.ssh-agent"

  # Check if ssh-agent is already running
  if [[ -f "$ssh_env_cache" ]]; then
    source "$ssh_env_cache" > /dev/null

    # Test if $SSH_AUTH_SOCK is visible
    zmodload zsh/net/socket
    if [[ -S "$SSH_AUTH_SOCK" ]] && zsocket "$SSH_AUTH_SOCK" 2>/dev/null; then
      return 0
    fi
  fi

  # start ssh-agent and setup environment
  (
    umask 066
    ssh-agent -s >! "$ssh_env_cache"
  )
  source "$ssh_env_cache" > /dev/null
}

_start_agent
unfunction _start_agent
