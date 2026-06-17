.PHONY: neovim tmux-conf node

neovim:
	@chmod +x neovim-setting/init_nvim.sh
	@cd neovim-setting && ./init_nvim.sh

tmux-conf:
	@chmod +x tmux-setting/init_tmux_conf.sh
	@cd tmux-setting && ./init_tmux_conf.sh

node:
	@chmod +x node-setting/init_node.sh
	@cd node-setting && ./init_node.sh "$(VERSION)"
