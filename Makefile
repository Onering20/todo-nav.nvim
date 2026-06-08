.PHONY: test lint

# Run the busted-style specs headlessly. Requires plenary.nvim reachable from
# tests/minimal_init.lua (sibling checkout or standard pack/lazy path).
test:
	nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal_init.lua' }"

# Quick smoke check that every module loads.
lint:
	nvim --headless --noplugin -u NONE \
		-c "set rtp+=." \
		-c "lua require('todo-nav'); require('todo-nav.health'); require('todo-nav.keymaps')" \
		-c "qa"
