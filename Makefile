.PHONY: test

test:
	nvim --headless -c "PlenaryBustedDirectory tests/clapi {minimal_init = 'tests/minimal_init.lua'}"
