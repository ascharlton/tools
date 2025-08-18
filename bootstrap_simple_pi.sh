#!/bin/bash
set -e  # exit on any error
set -x  # show commands for debugging

# Ensure .ssh directory exists
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Pre-load GitHub host key to avoid interactive prompt
ssh-keygen -F github.com || ssh-keyscan github.com >> "$HOME/.ssh/known_hosts"

# Check if SSH key exists, generate if missing
KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEY" ]; then
    ssh-keygen -t ed25519 -C "ascharlton@gmail.com" -f "$KEY" -N ""
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add "$KEY"

# Test GitHub SSH authentication (non-interactive)
ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "successfully authenticated" && \
    echo "✅ SSH authentication with GitHub works!" || \
    (echo "⚠️ SSH authentication failed!" && exit 1)

# Clone or update tools repo
REPO_DIR="$HOME/repos/tools"
mkdir -p "$REPO_DIR"
if [ ! -d "$REPO_DIR" ]; then
    git clone git@github.com:ascharlton/tools.git "$REPO_DIR"
else
    cd "$REPO_DIR"
    git pull
fi

echo "✅ Bootstrap complete!"

