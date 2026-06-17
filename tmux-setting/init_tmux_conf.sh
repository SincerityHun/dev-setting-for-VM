#!/bin/bash
set -euo pipefail

TMUX_CONF="$HOME/.tmux.conf"

if [ -e "$TMUX_CONF" ] || [ -L "$TMUX_CONF" ]; then
    BACKUP_PATH="$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing tmux config to $BACKUP_PATH"
    mv "$TMUX_CONF" "$BACKUP_PATH"
fi

echo "Creating tmux config at $TMUX_CONF"
{
    echo "set -g mouse on"
    echo "set-option -g history-limit 50000"
    echo "set -g set-clipboard on"
} > "$TMUX_CONF"

echo "tmux config setup complete!"
