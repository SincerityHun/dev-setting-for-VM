.PHONY: neovim tmux-conf node direnv-setting uv-setting gh-setting gh-check-token

neovim:
	@chmod +x neovim-setting/init_nvim.sh
	@cd neovim-setting && ./init_nvim.sh

tmux-conf:
	@chmod +x tmux-setting/init_tmux_conf.sh
	@cd tmux-setting && ./init_tmux_conf.sh

node:
	@chmod +x node-setting/init_node.sh
	@cd node-setting && ./init_node.sh "$(VERSION)"

direnv-setting:
	@chmod +x direnv-setting/init_direnv.sh
	@cd direnv-setting && ./init_direnv.sh

uv-setting:
	@chmod +x uv-setting/init_uv.sh
	@cd uv-setting && ./init_uv.sh

gh-setting:
	@chmod +x gh-setting/init_gh.sh
	@cd gh-setting && ./init_gh.sh

gh-check-token:
	@if [ -z "$$GH_TOKEN" ]; then \
		echo "GH_TOKEN is NOT set. Add 'export GH_TOKEN=<your token>' to .envrc and run 'direnv allow'."; \
		exit 1; \
	else \
		echo "GH_TOKEN is set."; \
	fi
