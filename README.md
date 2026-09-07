# dev-setting-for-VM

VM development environment setup scripts.

## Usage

### Neovim

- Install Neovim and copy the bundled config:

- `make neovim`

### tmux

- Create `~/.tmux.conf`:

- `make tmux-conf`

### Node.js

- Install the latest Current Node.js with nvm:

- `make node`

- Install a specific Node.js version with nvm:

- `make node VERSION=22.11.0`

### direnv

- Install direnv and add the bash hook to `~/.bashrc`:

- `make direnv-setting`

- Restart your shell or run `source ~/.bashrc` after setup. Project `.envrc` files still need to be allowed manually with `direnv allow`.

### uv

- Install uv and ensure `~/.local/bin` is available in bash:

- `make uv-setting`

- Restart your shell or run `source ~/.bashrc` after setup.

### GitHub CLI (gh)

- Install the latest gh from the official release `.deb` without sudo (Ubuntu only):

- `make gh-setting`

- Check that the `GH_TOKEN` environment variable is set:

- `make gh-check-token`

- Manage `GH_TOKEN` via a project `.envrc` (`export GH_TOKEN=<your token>`) and run `direnv allow`. gh authenticates automatically once `GH_TOKEN` is set.
