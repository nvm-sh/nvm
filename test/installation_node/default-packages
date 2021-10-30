#!/bin/sh

FILE="$NVM_DIR/default-packages"

die () { echo "$@" ; cleanup ; exit 1; }
setup () {
  if [ -f $FILE ]; then
    ORIG_DEFAULT_PACKAGES=$(cat $FILE)
    mkdir ./tmp/ ||:
    mv $FILE ./tmp/default-packages ||:
  fi
  touch $FILE
}
cleanup () {
  rm -rf "$(nvm_version_path v6.10.1)" $FILE
  if [ "$ORIG_DEFAULT_PACKAGES" != "" ]; then
    rm -rf ./tmp/
    echo "$ORIG_DEFAULT_PACKAGES" > $FILE
  fi
}

setup

\. ../../nvm.sh

cat > $FILE << EOF
rimraf
object-inspect@1.0.2

# commented-package

stevemao/left-pad
daytime
EOF

printf %s "$(cat "${FILE}")" > $FILE # strip trailing newline

nvm install v6.10.1 2>&1
EXIT_CODE=$?
[ "_$EXIT_CODE" = "_0" ] || die "expected 'nvm install v6.10.1' to exit with 0, got $EXIT_CODE"

nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'rimraf'
if [ -z "$?" ]; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'rimraf'' to exit with 0, got $?"
fi

nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'daytime'
if [ -z "$?" ]; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'daytime'' to exit with 0, got $?"
fi

cleanup

setup

\. ../../nvm.sh

cat > $FILE << EOF
rimraf
object-inspect@1.0.2

# commented-package

stevemao/left-pad
EOF

nvm install v6.10.1 --skip-default-packages 2>&1
EXIT_CODE=$?
[ "_$EXIT_CODE" = "_0" ] || die "expected 'nvm install v6.10.1' to exit with 0, got $EXIT_CODE"

if nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'rimraf'; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'rimraf'' to be empty"
fi

cleanup

setup

cat > $FILE << EOF
not~a~package~name
EOF

nvm install v6.10.1
EXIT_CODE=$?
[ "_$EXIT_CODE" = "_0" ] || die "expected 'nvm install v6.10.1' to exit with 0, got $EXIT_CODE"

if nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'not~a~package~name'; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'not~a~package~name'' to exit with 1, got $?"
fi

cleanup

setup

cat > $FILE << EOF
object-inspect @ 1.0.2
EOF

nvm install v6.10.1 2>&1
EXIT_CODE=$?
[ "_$EXIT_CODE" = "_1" ] || die "expected 'nvm install v6.10.1' to exit with 1, got $EXIT_CODE"

if nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'object-inspect'; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'object-inspect'' to exit with 1, got $?"
fi

cleanup

setup

rm -rf $FILE

nvm install v6.10.1 2>&1
EXIT_CODE=$?
[ "_$EXIT_CODE" = "_0" ] || die "expected 'nvm install v6.10.1' to exit with 0, got $EXIT_CODE"

if nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'object-inspect'; then
  die "expected 'nvm exec v6.10.1 npm ls -g --depth=0 | grep -q 'object-inspect'' to exit with 1, got $?"
fi

touch $FILE

cleanup
