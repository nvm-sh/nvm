URCHIN=`which urchin`
SHELLS=sh bash dash ksh zsh
TEST_SUITE=fast

.PHONY: $(SHELLS) test

$(SHELLS):
	@printf '\n\033[0;34m%s\033[0m\n' "Running tests in $@"
	@$@ $(URCHIN) -f test/$(TEST_SUITE)

test: $(SHELLS)
	@$(URCHIN) -f test/slow 

default: test

