#!/bin/bash
set -e

echo "=== Raspberry Pi Bootstrap ==="

# --- Install required packages ---
sudo apt update
sudo apt install -y git openssh-client curl jq

# --- Configure Git ---
git config --global user.name "ascharlton"
git config --global user.email "ascharlton@gmail.com"
git config --global core.editor vim   # or nano

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

# --- Test GitHub connection ---
echo "Testing GitHub SSH connection..."
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts


if ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH authentication with GitHub works!"
else
    echo "⚠️  SSH authentication failed. Likely your Pi’s key is not added to GitHub."
    echo
    echo "👉 Please copy the following public key and add it to GitHub:"
    echo
    echo "----- BEGIN PUBLIC KEY -----"
    cat ~/.ssh/id_ed25519.pub
    echo "----- END PUBLIC KEY -----"
    echo
    echo "Then go to: https://github.com/settings/keys → New SSH key"
    echo "After adding it, rerun this script."
    exit 1
fi

# --- Detect default branch of tools repo ---
echo "Checking default branch for tools repo..."
DEFAULT_BRANCH=$(curl -s https://api.github.com/repos/ascharlton/tools | jq -r .default_branch)
echo "Default branch is: $DEFAULT_BRANCH"

# --- Clone tools repo if not already present ---
mkdir -p ~/repos
cd ~/repos
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

