#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is required}"

CURRENT_SHELL="$(basename "${SHELL:-}")"
PROFILE="$HOME/.bashrc"
LOCAL_BIN="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
DIRENV_HOOK='eval "$(direnv hook bash)"'

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

if ! command -v direnv >/dev/null 2>&1; then
    echo "Installing direnv..."
    curl -sfL https://direnv.net/install.sh | bash
else
    echo "direnv is already installed."
fi

if ! command -v direnv >/dev/null 2>&1; then
    echo "direnv installation failed: direnv was not found in PATH" >&2
    exit 1
fi

if ! grep -Fq "$DIRENV_HOOK" "$PROFILE"; then
    echo "Adding direnv hook to $PROFILE"
    {
        echo ''
        echo "$DIRENV_HOOK"
    } >> "$PROFILE"
else
    echo "direnv hook already exists in $PROFILE"
fi

echo "Verifying installation..."
echo "direnv: $(direnv --version)"
echo "direnv setup complete! Restart your shell or run: source $PROFILE"
