#!/bin/bash
# initialize git submodules during vercel build

set -e  # Exit immediately on any error

# Use HTTPS with token if available, otherwise try SSH
if [ -n "$GITHUB_TOKEN" ]; then
  # Configure git to use token for HTTPS
  # This allows access to private repositories without SSH setup
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "git@github.com:"
  echo "Configured git to use GitHub token for private repository access"
elif [ -n "$GIT_SSH_KEY" ]; then
  # Fallback to SSH if token is not available
  mkdir -p ~/.ssh || { echo "Failed to create ~/.ssh directory" >&2; exit 1; }
  printf '%s' "$GIT_SSH_KEY" > ~/.ssh/id_ed25519 || { echo "Failed to write SSH key" >&2; exit 1; }
  chmod 600 ~/.ssh/id_ed25519 || { echo "Failed to set SSH key permissions" >&2; exit 1; }
  ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
  echo "Configured SSH for private repository access"
else
  echo "Warning: No GITHUB_TOKEN or GIT_SSH_KEY found. Private submodule may fail to clone." >&2
fi

# initialize and update submodules
git submodule update --init --recursive --remote

echo "submodules initialized successfully"

