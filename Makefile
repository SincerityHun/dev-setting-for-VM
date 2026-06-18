.PHONY: neovim tmux-conf node direnv-setting uv-setting

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
