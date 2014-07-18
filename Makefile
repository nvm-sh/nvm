URCHIN=`which urchin`
SHELLS=sh bash dash ksh zsh
TEST_SUITE=fast

.PHONY: $(SHELLS) test verify-tag release

$(SHELLS):
	@printf '\n\033[0;34m%s\033[0m\n' "Running tests in $@"
	@$@ $(URCHIN) -f test/$(TEST_SUITE)

test: $(SHELLS)
	@$(URCHIN) -f test/slow 

default: test

verify-tag:
ifndef TAG
	$(error TAG is undefined)
endif

release: verify-tag
	@ OLD_TAG=`git describe --abbrev=0 --tags` && \
		replace "$${OLD_TAG/v/}" "$(TAG)" -- nvm.sh install.sh README.markdown package.json && \
		git commit -m "v$(TAG)" nvm.sh install.sh README.markdown package.json && \
		git tag "v$(TAG)"

