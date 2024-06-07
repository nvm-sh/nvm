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

parse_json() {
  local json
  json="$1"
  local key
  key=""
  local value
  value=""
  local output
  output=""
  local in_key
  in_key=0
  local in_value
  in_value=0
  local in_string
  in_string=0
  local escaped
  escaped=0
  local buffer
  buffer=""
  local char
  local len
  len=${#json}
  local arr_index
  arr_index=0
  local in_array
  in_array=0

  for ((i = 0; i < len; i++)); do
    char="${json:i:1}"

    if [ "$in_string" -eq 1 ]; then
      if [ "$escaped" -eq 1 ]; then
        buffer="$buffer$char"
        escaped=0
      elif [ "$char" = "\\" ]; then
        escaped=1
      elif [ "$char" = "\"" ]; then
        in_string=0
        if [ "$in_key" -eq 1 ]; then
          key="$buffer"
          buffer=""
          in_key=0
        elif [ "$in_value" -eq 1 ]; then
          value="$buffer"
          buffer=""
          output="$output$key=\"$value\"\n"
          in_value=0
        elif [ "$in_array" -eq 1 ]; then
          value="$buffer"
          buffer=""
          output="$output$arr_index=\"$value\"\n"
          arr_index=$((arr_index + 1))
        fi
      else
        buffer="$buffer$char"
      fi
      continue
    fi

    case "$char" in
      "\"")
        in_string=1
        buffer=""
        if [ "$in_value" -eq 0 ] && [ "$in_array" -eq 0 ]; then
          in_key=1
        fi
        ;;
      ":")
        in_value=1
        ;;
      ",")
        if [ "$in_value" -eq 1 ]; then
          in_value=0
        fi
        ;;
      "[")
        in_array=1
        ;;
      "]")
        in_array=0
        ;;
      "{" | "}")
        ;;
      *)
        if [ "$in_value" -eq 1 ] && [ "$char" != " " ] && [ "$char" != "\n" ] && [ "$char" != "\t" ]; then
          buffer="$buffer$char"
        fi
        ;;
    esac
  done

  printf "%b" "$output"
}

extract_value() {
  local key
  key="$1"
  local parsed
  parsed="$2"
  echo "$parsed" | grep "^$key=" | cut -d'=' -f2 | tr -d '"'
}
