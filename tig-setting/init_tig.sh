#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is required}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CURRENT_SHELL="$(basename "${SHELL:-}")"
PROFILE="$HOME/.bashrc"
LOCAL_BIN="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
ALIAS_LINE="alias tl='tig --all'"
TIGRC="$HOME/.tigrc"
TIG_RELEASE_API="https://api.github.com/repos/jonas/tig/releases/latest"

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
require_command tar
require_command sha256sum
require_command gcc
require_command make

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

if ! command -v tig >/dev/null 2>&1; then
    echo "Fetching latest tig release info..."
    TARBALL_URL="$(curl -fsSL "$TIG_RELEASE_API" \
        | grep -oE '"browser_download_url": *"[^"]*/tig-[0-9.]+\.tar\.gz"' \
        | grep -oE 'https://[^"]+' \
        | head -1)"

    if [ -z "$TARBALL_URL" ]; then
        echo "Failed to find a source tarball in the latest tig release." >&2
        exit 1
    fi

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    TARBALL="$(basename "$TARBALL_URL")"

    echo "Downloading $TARBALL_URL"
    curl -fL --progress-bar -o "$TMP_DIR/$TARBALL" "$TARBALL_URL"
    curl -fsSL -o "$TMP_DIR/$TARBALL.sha256" "$TARBALL_URL.sha256"

    echo "Verifying checksum..."
    (cd "$TMP_DIR" && sha256sum -c "$TARBALL.sha256")

    echo "Building tig (no sudo required)..."
    tar xzf "$TMP_DIR/$TARBALL" -C "$TMP_DIR"
    cd "$TMP_DIR/${TARBALL%.tar.gz}"
    if ! ./configure --prefix="$HOME/.local"; then
        echo "tig configure failed. ncursesw headers may be missing: sudo apt install libncursesw5-dev" >&2
        exit 1
    fi
    make -j"$(nproc)"
    make install
    cd "$SCRIPT_DIR"
else
    echo "tig is already installed."
fi

if ! command -v tig >/dev/null 2>&1; then
    echo "tig installation failed: tig was not found in PATH" >&2
    exit 1
fi

if [ -e "$TIGRC" ] || [ -L "$TIGRC" ]; then
    BACKUP_PATH="$TIGRC.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing tig config to $BACKUP_PATH"
    mv "$TIGRC" "$BACKUP_PATH"
fi

echo "Copying tig config to $TIGRC"
cp "$SCRIPT_DIR/tigrc" "$TIGRC"

if ! grep -Fq "$ALIAS_LINE" "$PROFILE"; then
    echo "Adding tl alias to $PROFILE"
    {
        echo ''
        echo "$ALIAS_LINE"
    } >> "$PROFILE"
else
    echo "tl alias already exists in $PROFILE"
fi

echo "Verifying installation..."
echo "tig: $(tig --version | head -1)"
echo "tig setup complete! Restart your shell or run: source $PROFILE"
