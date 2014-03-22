URCHIN=`which urchin`
SHELLS=sh bash dash ksh zsh

.PHONY: $(SHELLS) test

fast: $(SHELLS)

$(SHELLS):
	@printf '\n\033[0;34m%s\033[0m\n' "Running tests in $@"
	@$@ $(URCHIN) -f test/fast

test: fast
	@$(URCHIN) -f test/slow 

default: test