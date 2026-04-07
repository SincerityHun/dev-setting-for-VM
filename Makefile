.PHONY: neovim

neovim:
	@chmod +x neovim-setting/init_nvim.sh
	@cd neovim-setting && ./init_nvim.sh
