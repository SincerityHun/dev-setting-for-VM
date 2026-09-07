#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is required}"

CURRENT_SHELL="$(basename "${SHELL:-}")"
PROFILE="$HOME/.bashrc"
LOCAL_BIN="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
GH_RELEASE_API="https://api.github.com/repos/cli/cli/releases/latest"

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

if [ ! -r /etc/os-release ] || ! grep -q '^ID=ubuntu$' /etc/os-release; then
    echo "Unsupported OS: this setup currently supports Ubuntu only." >&2
    exit 1
fi

require_command curl
require_command dpkg-deb

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  DEB_ARCH="amd64" ;;
    aarch64) DEB_ARCH="arm64" ;;
    *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

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

if ! command -v gh >/dev/null 2>&1; then
    echo "Fetching latest gh release info..."
    DEB_URL="$(curl -fsSL "$GH_RELEASE_API" \
        | grep -oE "\"browser_download_url\": *\"[^\"]*_linux_${DEB_ARCH}\.deb\"" \
        | grep -oE 'https://[^"]+' \
        | head -1)"

    if [ -z "$DEB_URL" ]; then
        echo "Failed to find a linux_${DEB_ARCH} .deb asset in the latest gh release." >&2
        exit 1
    fi

    TMP_DEB="$(mktemp --suffix=.deb)"
    TMP_EXTRACT="$(mktemp -d)"
    trap 'rm -rf "$TMP_DEB" "$TMP_EXTRACT"' EXIT

    echo "Downloading $DEB_URL"
    curl -fL --progress-bar -o "$TMP_DEB" "$DEB_URL"

    echo "Extracting gh (no sudo required)..."
    dpkg-deb -x "$TMP_DEB" "$TMP_EXTRACT"
    install -m 755 "$TMP_EXTRACT/usr/bin/gh" "$LOCAL_BIN/gh"
else
    echo "gh is already installed."
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "gh installation failed: gh was not found in PATH" >&2
    exit 1
fi

echo "Verifying installation..."
echo "gh: $(gh --version | head -1)"

if [ -z "${GH_TOKEN:-}" ]; then
    echo ""
    echo "NOTE: GH_TOKEN is NOT set in the current environment."
    echo "Add 'export GH_TOKEN=<your token>' to your project .envrc and run 'direnv allow'."
    echo "gh authenticates automatically once GH_TOKEN is set."
else
    echo "GH_TOKEN is set."
fi

echo "gh setup complete! Restart your shell or run: source $PROFILE"
