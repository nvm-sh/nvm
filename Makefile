URCHIN=`which urchin`
SHELLS=sh bash dash ksh zsh

.PHONY: $(SHELLS) test test_shell

fast: $(SHELLS)

$(SHELLS):
	@printf '\n\033[0;34m%s\033[0m\n' "Running tests in $@"
	@$@ $(URCHIN) -f test/fast

test: fast
	@$(URCHIN) -f test/slow 

test_shell:
	@printf '\n\033[0;34m%s\033[0m\n' "Running tests in $(SHELL)"
	@$(SHELL) $(URCHIN) -f test/$(TEST_SUITE)

default: test

