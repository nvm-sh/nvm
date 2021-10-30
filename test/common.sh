assert_ok() {
  local FUNCTION=$1
  shift

  $($FUNCTION $@) || die '"'"$FUNCTION $@"'" should have succeeded, but failed'
}

assert_not_ok() {
  local FUNCTION=$1
  shift

  ! $($FUNCTION $@) || die '"'"$FUNCTION $@"'" should have failed, but succeeded'
}

strip_colors() {
  while read -r line; do
    echo "$line" | LC_ALL=C command sed 's/\[[ -?]*[@-~]//g'
  done
}

make_echo() {
  echo "#!/bin/sh" > "$1"
  echo "echo \"${2}\"" > "$1"
  chmod a+x "$1"
}

make_fake_node() {
  local VERSION
  VERSION="${1-}"
  [ -n "${VERSION}" ] || return 1

  local FORMATTED_VERSION
  FORMATTED_VERSION="$(nvm_format_version "${VERSION}")"

  local BIN_PATH
  BIN_PATH="$(nvm_version_path "${FORMATTED_VERSION}")/bin"
  [ "${BIN_PATH}" != "/bin" ] || {
    echo >&2 'nvm_version_path was empty'
    return 5
  }

  mkdir -p "${BIN_PATH}" || {
    echo >&2 'unable to make bin dir'
    return 2
  }

  make_echo "${BIN_PATH}/node" "${VERSION}" || {
    echo >&2 'unable to make fake node bin'
    return 3
  }

  nvm_is_version_installed "${FORMATTED_VERSION}" || {
    echo >&2 'fake node is not installed'
    return 4
  }
}

make_fake_iojs() {
  local VERSION
  VERSION="${1-}"
  [ -n "${VERSION}" ] || return 1

  local FORMATTED_VERSION
  FORMATTED_VERSION="$(nvm_format_version "iojs-${VERSION}")"

  local BIN_PATH
  BIN_PATH="$(nvm_version_path "${FORMATTED_VERSION}")/bin"
  [ "${BIN_PATH}" != "/bin" ] || {
    echo >&2 'nvm_version_path was empty'
    return 5
  }

  mkdir -p "${BIN_PATH}" || {
    echo >&2 'unable to make bin dir'
    return 2
  }

  make_echo "${BIN_PATH}/node" "${VERSION}" || {
    echo >&2 'unable to make fake node bin'
    return 3
  }
  make_echo "${BIN_PATH}/iojs" "${VERSION}" || {
    echo >&2 'unable to make fake iojs bin'
    return 3
  }

  nvm_is_version_installed "${FORMATTED_VERSION}" || {
    echo >&2 'fake iojs is not installed'
    return 4
  }
}

watch() {
  $@ &
  local JOB
  JOB=$!
  while true; do sleep 15; >&2 echo '* ping *'; done &
  wait $JOB;
  local EXIT_CODE
  EXIT_CODE=$?
  kill %2;
  return $EXIT_CODE
}
