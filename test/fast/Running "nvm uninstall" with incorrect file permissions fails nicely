#!/bin/sh

set -ex

\. ../../nvm.sh
\. ../common.sh

make_fake_node v0.0.1
sudo touch ""$(nvm_version_path v0.0.1)"/sudo"

RETURN_MESSAGE="$(nvm uninstall v0.0.1 2>&1 || echo)"
CHECK_FOR="Cannot uninstall, incorrect permissions on installation folder"

[ "${RETURN_MESSAGE#*$CHECK_FOR}" != "$RETURN_MESSAGE" ] || exit 1
