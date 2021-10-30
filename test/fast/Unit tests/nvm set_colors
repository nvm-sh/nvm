#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset NVM_COLORS
  unset -f nvm_has_colors
  if [ -n TEMP_NVM_COLORS ]; then
    export NVM_COLORS=TEMP_NVM_COLORS
  fi
  unset TEMP_NVM_COLORS
}

\. ../../../nvm.sh
# NVM_COLORS is not set
if [ -n ${NVM_COLORS} ]; then
  export TEMP_NVM_COLORS=NVM_COLORS
  unset NVM_COLORS
fi

# test valid setting colors/
nvm set-colors rgbyc
OUTPUT="${NVM_COLORS}"
EXPECTED_OUTPUT="rgbyc"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "NVM_SET_COLORS failed with valid input; got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

# test invalid 4 colors
set +ex
OUTPUT="$(echo $(nvm set-colors rgby 2>&1) | awk '{ print substr($0, length($0)-92, 93); }')"
EXPECTED_OUTPUT="$(command printf %b "\033[1;37mPlease pass in five \033[1;31mvalid color codes\033[1;37m. Choose from: rRgGbBcCyYmMkKeW\033[0m")"
set -ex

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "NVM_SET_COLORS did not fail with invalid input; got >${OUTPUT}, < expected >${EXPECTED_OUTPUT}<"

# test invalid color codes
set +ex
OUTPUT="$(echo $(nvm set-colors p3gq7 2>&1) | awk '{ print substr($0, length($0)-92, 93); }')"
EXPECTED_OUTPUT="$(command printf %b "\033[1;37mPlease pass in five \033[1;31mvalid color codes\033[1;37m. Choose from: rRgGbBcCyYmMkKeW\033[0m")"
set -ex
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "NVM_SET_COLORS did not fail with invalid input; got >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

#test system does not support at least 8 colors
nvm_has_colors() { return 1; }
set +ex
OUTPUT="$(echo $(nvm set-colors mcyGb 2>&1) | awk '{ print substr($0, length($0)-76, 77); }')"
set -ex
EXPECTED_OUTPUT="WARNING: Colors may not display because they are not supported in this shell."
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "NVM_SET_COLORS did not recognize lack of color support; got >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

cleanup
