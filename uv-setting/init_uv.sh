#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is required}"

CURRENT_SHELL="$(basename "${SHELL:-}")"
PROFILE="$HOME/.bashrc"
LOCAL_BIN="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required command not found: $command_name" >&2
        exit 1
    fi
}

if [ "$CURRENT_SHELL" != "bash" ]; then
    echo "Unsupported shell: ${SHELL:-unknown}. This setup currently supports bash only." >&2
    exit 1
fi

require_command curl

mkdir -p "$LOCAL_BIN"
touch "$PROFILE"

if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    export PATH="$LOCAL_BIN:$PATH"
fi

if ! grep -Fq "$PATH_LINE" "$PROFILE"; then
    echo "Adding $LOCAL_BIN to PATH in $PROFILE"
    {
        echo ''
        echo "$PATH_LINE"
    } >> "$PROFILE"
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed."
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "uv installation failed: uv was not found in PATH" >&2
    exit 1
fi

echo "Verifying installation..."
echo "uv: $(uv --version)"
echo "uv setup complete! Restart your shell or run: source $PROFILE"
