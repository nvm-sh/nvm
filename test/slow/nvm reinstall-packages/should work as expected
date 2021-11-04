#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm exec 0.10.28 npm install -g npm@~1.4.11 && nvm install-latest-npm # this is required because before 1.4.10, npm ls doesn't indicated linked packages
nvm exec 0.10.29 npm install -g npm@~1.4.11 && nvm install-latest-npm # this is required because before 1.4.10, npm ls doesn't indicated linked packages

nvm use 0.10.28
(cd test-npmlink && npm link)

EXPECTED_PACKAGES="autoprefixer bower david grunt-cli grunth-cli http-server jshint marked node-gyp npmlist postcss recursive-blame spawn-sync test-npmlink uglify-js yo"
EXPECTED_PACKAGES_INSTALL="autoprefixer bower david@11 grunt-cli grunth-cli http-server jshint marked node-gyp@7 npmlist postcss@4 recursive-blame spawn-sync test-npmlink uglify-js yo@1"

echo "$EXPECTED_PACKAGES_INSTALL" | sed -e 's/test-npmlink //' | xargs npm install -g --quiet

get_packages() {
  npm list -g --depth=0 | \sed -e '1 d' -e 's/^.* \(.*\)@.*/\1/' -e '/^npm$/ d' | xargs
}

nvm use 0.10.29
ORIGINAL_PACKAGES=$(get_packages)

nvm reinstall-packages 0.10.28
FINAL_PACKAGES=$(get_packages)

[ "$FINAL_PACKAGES" = "$EXPECTED_PACKAGES" ] || die "final packages ($FINAL_PACKAGES) did not match expected packages ($EXPECTED_PACKAGES)"
[ "$ORIGINAL_PACKAGES" != "$FINAL_PACKAGES" ] || die "original packages matched final packages ($ORIGINAL_PACKAGES)"

[ $(test-npmlink) = 'ok' ] || die "failed to run test-npmlink"
