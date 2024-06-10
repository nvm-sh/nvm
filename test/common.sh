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


# JSON parsing from https://gist.github.com/assaf/ee377a186371e2e269a7
nvm_json_throw() {
  nvm_err "$*"
  exit 1
}

nvm_json_awk_egrep() {
  local pattern_string
  pattern_string="${1}"

  awk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, RLENGTH);
      print token;
      $0=substr($0, start+RLENGTH);
    }
  }' "pattern=${pattern_string}"
}

nvm_json_tokenize() {
  local GREP
  GREP='grep -Eao'

  local ESCAPE
  local CHAR

  # if echo "test string" | grep -Eo "test" > /dev/null 2>&1; then
  #   ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  #   CHAR='[^[:cntrl:]"\\]'
  # else
    GREP=nvm_json_awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  # fi

  local STRING
  STRING="\"${CHAR}*(${ESCAPE}${CHAR}*)*\""
  local NUMBER
  NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD
  KEYWORD='null|false|true'
  local SPACE
  SPACE='[[:space:]]+'

  $GREP "${STRING}|${NUMBER}|${KEYWORD}|${SPACE}|." | TERM=dumb grep -Ev "^${SPACE}$"
}

_json_parse_array() {
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :; do
        _json_parse_value "${1}" "${index}"
        index=$((index+1))
        ary="${ary}${value}"
        read -r token
        case "${token}" in
          ']') break ;;
          ',') ary="${ary}," ;;
          *) nvm_json_throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  :
}

_json_parse_object() {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :; do
        case "${token}" in
          '"'*'"') key="${token}" ;;
          *) nvm_json_throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "${token}" in
          ':') ;;
          *) nvm_json_throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        _json_parse_value "${1}" "${key}"
        obj="${obj}${key}:${value}"
        read -r token
        case "${token}" in
          '}') break ;;
          ',') obj="${obj}," ;;
          *) nvm_json_throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  :
}

_json_parse_value() {
  local jpath="${1:+$1,}$2"
  local isleaf=0
  local isempty=0
  local print=0

  case "$token" in
    '{') _json_parse_object "${jpath}" ;;
    '[') _json_parse_array  "${jpath}" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) nvm_json_throw "EXPECTED value GOT >${token:-EOF}<" ;;
    *)
      value=$token
      isleaf=1
      [ "${value}" = '""' ] && isempty=1
    ;;
  esac

  [ "${value}" = '' ] && return
  [ "${isleaf}" -eq 1 ] && [ $isempty -eq 0 ] && print=1
  [ "${print}" -eq 1 ] && printf "[%s]\t%s\n" "${jpath}" "${value}"
  :
}

_json_parse() {
  read -r token
  _json_parse_value
  read -r token
  case "${token}" in
    '') ;;
    *) nvm_json_throw "EXPECTED EOF GOT >${token}<" ;;
  esac
}

nvm_json_extract() {
  nvm_json_tokenize | _json_parse | grep -e "${1}" | awk '{print $2 $3}'
}
