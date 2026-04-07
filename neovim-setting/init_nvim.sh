#!/bin/bash

# Neovim configuration init script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ARCH="$(uname -m)"
OS="$(uname -s)"

# Ensure ~/.local/bin is in PATH immediately
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    export PATH="$LOCAL_BIN:$PATH"
fi
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added $LOCAL_BIN to PATH in .bashrc"
fi

# Install Neovim locally
echo "Installing Neovim..."
if command -v nvim &> /dev/null; then
    echo "Neovim is already installed."
else
    NVIM_VERSION="0.12.0"
    NVIM_DIR="$HOME/.local"

    case "$OS" in
        Linux)
            case "$ARCH" in
                x86_64)  NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz" ;;
                aarch64) NVIM_ARCHIVE="nvim-linux-arm64.tar.gz" ;;
                *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            ;;
        Darwin)
            case "$ARCH" in
                arm64)   NVIM_ARCHIVE="nvim-macos-arm64.tar.gz" ;;
                x86_64)  NVIM_ARCHIVE="nvim-macos-x86_64.tar.gz" ;;
                *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $OS"; exit 1 ;;
    esac

    TMP_FILE="$(mktemp)"
    echo "Downloading Neovim ${NVIM_VERSION}..."
    curl -fL --progress-bar -o "$TMP_FILE" \
        "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ARCHIVE}"
    echo "Extracting..."
    tar xz --strip-components=1 -C "$NVIM_DIR" -f "$TMP_FILE"
    rm -f "$TMP_FILE"

    echo "Neovim ${NVIM_VERSION} installed to $NVIM_DIR/bin/nvim"
fi

# Backup existing nvim config
if [ -d "$HOME/.config/nvim" ]; then
    echo "Backing up existing nvim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
fi

# Create .config directory
mkdir -p "$HOME/.config"

# Copy nvim folder
echo "Copying nvim config..."
cp -r "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

# Install ripgrep locally
echo "Installing ripgrep..."
if command -v rg &> /dev/null; then
    echo "ripgrep is already installed."
else
    RG_VERSION="15.0.0"

    case "$OS" in
        Linux)
            case "$ARCH" in
                x86_64)  TARGET="x86_64-unknown-linux-musl" ;;
                i686)    TARGET="i686-unknown-linux-gnu" ;;
                aarch64) TARGET="aarch64-unknown-linux-gnu" ;;
                armv7l)  TARGET="armv7-unknown-linux-gnueabihf" ;;
                s390x)   TARGET="s390x-unknown-linux-gnu" ;;
                *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            ;;
        Darwin)
            case "$ARCH" in
                arm64)   TARGET="aarch64-apple-darwin" ;;
                x86_64)  TARGET="x86_64-apple-darwin" ;;
                *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $OS"; exit 1 ;;
    esac

    ARCHIVE="ripgrep-${RG_VERSION}-${TARGET}.tar.gz"

    TMP_FILE="$(mktemp)"
    echo "Downloading ripgrep ${RG_VERSION}..."
    curl -fL --progress-bar -o "$TMP_FILE" \
        "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${ARCHIVE}"
    echo "Extracting..."
    tar xz --strip-components=1 -C "$LOCAL_BIN" -f "$TMP_FILE" "ripgrep-${RG_VERSION}-${TARGET}/rg"
    rm -f "$TMP_FILE"

    echo "ripgrep ${RG_VERSION} installed to $LOCAL_BIN/rg"
fi

echo "Setup complete!"
