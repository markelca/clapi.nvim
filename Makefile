.PHONY: test

test-unit:
	nvim --headless -c "PlenaryBustedDirectory tests/clapi/unit {minimal_init = 'tests/minimal_init.lua'}"
test-functional:
	nvim --headless -c "PlenaryBustedDirectory tests/clapi/functional {minimal_init = 'tests/lsp_init.lua'}"
