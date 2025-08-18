#!/bin/bash
# download:
# curl -fsSL -o ~/bootstrap_pi.sh https://raw.githubusercontent.com/ascharlton/tools/main/bootstrap_pi.sh
set -e

echo "=== Raspberry Pi Bootstrap ==="

# --- Install required packages ---
sudo apt update
sudo apt install -y vim git openssh-client curl jq

# --- Configure Git ---
git config --global user.name "ascharlton"
git config --global user.email "ascharlton@gmail.com"
git config --global core.editor nano   # or vim

# --- Ensure SSH key exists ---
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "No SSH key found, generating one..."
    ssh-keygen -t ed25519 -C "ascharlton@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "SSH key already exists."
fi

# --- Start SSH agent and add key ---
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# --- Ensure GitHub host key is known ---
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keygen -F github.com >/dev/null || ssh-keyscan github.com >> ~/.ssh/known_hosts

# --- Test GitHub SSH connection ---
echo "Testing GitHub SSH connection..."
if ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH authentication with GitHub works!"
else
    echo "⚠️ SSH authentication failed. Add the following public key to GitHub:"
    echo
    cat ~/.ssh/id_ed25519.pub
    echo
    echo "Go to: https://github.com/settings/keys → New SSH key"
    exit 1
fi

echo "clone repos"
# --- Clone or update tools repo ---
mkdir -p ~/repos
cd ~/repos

echo "Detecting default branch for tools repo..."
DEFAULT_BRANCH=$(curl -s https://api.github.com/repos/ascharlton/tools | jq -r .default_branch)
echo "Default branch is: $DEFAULT_BRANCH"

if [ ! -d "tools" ]; then
    echo "Cloning tools repo..."
    git clone --branch "$DEFAULT_BRANCH" git@github.com:ascharlton/tools.git
else
    echo "Tools repo already exists, pulling latest..."
    cd tools
    git checkout "$DEFAULT_BRANCH"
    git pull origin "$DEFAULT_BRANCH"
fi

echo "=== Bootstrap complete ==="

