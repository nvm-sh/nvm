#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset NVM_COLORS
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
OUTPUT=$(nvm_get_colors 1)
EXPECTED_OUTPUT='0;34m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (INSTALLED_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 2)
EXPECTED_OUTPUT='0;33m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (SYSTEM_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 3)
EXPECTED_OUTPUT='0;32m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (CURRENT_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 4)
EXPECTED_OUTPUT='0;31m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (NOT_INSTALLED_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 5)
EXPECTED_OUTPUT='0;37m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (DEFAULT_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 6)
EXPECTED_OUTPUT='1;33m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (LTS_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

# bad parameter
set +ex # needed for stderr
OUTPUT=$(nvm_get_colors bad 2>&1)
set -ex
EXPECTED_OUTPUT="Invalid color index, bad"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors did not have an error with bad output; got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

# NVM_COLORS is set
nvm set-colors rgbyc
OUTPUT=$(nvm_get_colors 1)
EXPECTED_OUTPUT='0;31m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (INSTALLED_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 2)
EXPECTED_OUTPUT='0;32m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (SYSTEM_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 3)
EXPECTED_OUTPUT='0;34m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (CURRENT_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 4)
EXPECTED_OUTPUT='0;33m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (NOT_INSTALLED_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 5)
EXPECTED_OUTPUT='0;36m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (DEFAULT_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

OUTPUT=$(nvm_get_colors 6)
EXPECTED_OUTPUT='1;32m'
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_colors failed to return default color (LTS_COLOR); got >${OUTPUT}< expected >${EXPECTED_OUTPUT}<"

cleanup
