#!/bin/bash

# Neovim configuration init script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
    RG_DIR="$HOME/.local/bin"
    mkdir -p "$RG_DIR"

    ARCH="$(uname -m)"
    OS="$(uname -s)"

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
            ARCHIVE="ripgrep-${RG_VERSION}-${TARGET}.tar.gz"
            curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${ARCHIVE}" \
                | tar xz --strip-components=1 -C "$RG_DIR" "ripgrep-${RG_VERSION}-${TARGET}/rg"
            ;;
        Darwin)
            case "$ARCH" in
                arm64)   TARGET="aarch64-apple-darwin" ;;
                x86_64)  TARGET="x86_64-apple-darwin" ;;
                *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            ARCHIVE="ripgrep-${RG_VERSION}-${TARGET}.tar.gz"
            curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${ARCHIVE}" \
                | tar xz --strip-components=1 -C "$RG_DIR" "ripgrep-${RG_VERSION}-${TARGET}/rg"
            ;;
        *)
            echo "Unsupported OS: $OS"; exit 1 ;;
    esac

    # Add to PATH if not already
    if [[ ":$PATH:" != *":$RG_DIR:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo "Added $RG_DIR to PATH in .bashrc"
    fi

    echo "ripgrep ${RG_VERSION} installed to $RG_DIR/rg"
fi

echo "Setup complete!"
