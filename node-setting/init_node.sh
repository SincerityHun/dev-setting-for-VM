#!/bin/bash
set -euo pipefail

NODE_VERSION="${1:-}"
NVM_VERSION="v0.40.5"
NVM_DIR="$HOME/.nvm"
PROFILE="$HOME/.bashrc"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required command not found: $command_name" >&2
        exit 1
    fi
}

require_command curl
require_command git

touch "$PROFILE"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Installing nvm ${NVM_VERSION}..."
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE="$PROFILE" bash
else
    echo "nvm is already installed at $NVM_DIR"
fi

if ! grep -q 'nvm.sh' "$PROFILE"; then
    echo "Adding nvm initialization to $PROFILE"
    {
        echo ''
        echo 'export NVM_DIR="$HOME/.nvm"'
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
    } >> "$PROFILE"
fi

# Load nvm in this script so installation and verification work immediately.
export NVM_DIR
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
else
    echo "nvm installation failed: $NVM_DIR/nvm.sh was not found" >&2
    exit 1
fi

if [ -n "$NODE_VERSION" ]; then
    echo "Installing Node.js ${NODE_VERSION}..."
    nvm install "$NODE_VERSION"
else
    echo "Installing latest Current Node.js..."
    nvm install node
fi

RESOLVED_NODE_VERSION="$(nvm current)"
nvm alias default "$RESOLVED_NODE_VERSION"
nvm use default

echo "Verifying installation..."
echo "nvm: $(nvm --version)"
echo "node: $(node --version)"
echo "npm: $(npm --version)"

echo "Node.js setup complete!"
