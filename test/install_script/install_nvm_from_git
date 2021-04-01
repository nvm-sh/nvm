#!/bin/sh

SAVE_NVM_DIR="$NVM_DIR"
SAVE_NVM_INSTALL_VERSION="$NVM_INSTALL_VERSION"

cleanup () {
  NVM_DIR="$SAVE_NVM_DIR"
  NVM_INSTALL_VERSION="$SAVE_NVM_INSTALL_VERSION"
  unset SAVE_NVM_DIR SAVE_NVM_INSTALL_VERSION
  unset -f die cleanup test_step get_head_ref get_head_changeset get_fetch_head_changeset \
    step_to_previous_changeset test_install_data test_install
}

die () { echo -e "$@" ; cleanup ;  exit 1; }

NVM_ENV=testing \. ../../install.sh

set -ex

# nvm_do_install is available
type install_nvm_from_git > /dev/null 2>&1 || die 'install_nvm_from_git is not available'

test_step() {
  echo -e "\e[33m$*\e[0m"
}

get_head_ref(){
  git --git-dir "$NVM_DIR"/.git --no-pager log --pretty=format:'%d' -1
}

get_head_changeset() {
  git --git-dir "$NVM_DIR"/.git rev-parse --verify HEAD
}

get_fetch_head_changeset() {
  git --git-dir "$NVM_DIR"/.git rev-parse --verify FETCH_HEAD
}

step_to_previous_changeset() {
  git --git-dir "$NVM_DIR"/.git fetch origin +"$(get_head_changeset)" --depth=2
  git --git-dir "$NVM_DIR"/.git reset --hard HEAD~1
}

# args:
#   - 1: current ref
#   - 2: current changeset
#   - 3: error message
#   - 4: ref to check ("" if none)
#   - 5: changeset to check ("" if none)
#   - 6: ref to avoid ("" if none)
test_install_data() {
  local current_ref="$1"
  local current_changeset="$2"
  local message="$3"
  local ref="$4"
  local changeset="$5"
  local avoid_ref="$6"

  if [ -n "$ref" ]; then
    echo "$current_ref" | grep -q "$ref" || die "install_nvm_from_git ${message} did not clone with ref ${ref}"
  fi

  local head_ref="$(git for-each-ref --points-at HEAD --format='%(refname:short)' 'refs/tags/')"
  if [ -n "${avoid_ref}" ] && [ "${head_ref}" != "${avoid_ref}"]; then
    echo "${current_ref}" | grep -q "$avoid_ref" && die "install_nvm_from_git ${message} did clone with unwanted ref ${avoid_ref}"
  fi

  if [ -n "$changeset" ]; then
    echo "${current_changeset}" | grep -q "${changeset}" || die "install_nvm_from_git ${message} did not clone with changeset ${changeset}"
  fi
}

# args:
#   - 1: version to install ("" for latest, tag, ref or changeset)
#   - 2: error message
#   - 3: ref to check ("" if none)
#   - 4: changeset to check ("" if none)
#   - 5: ref to avoid ("" if none)
test_install() {
  if [ -n "${1-}" ]; then
    export NVM_INSTALL_VERSION="$1"
  else
    unset NVM_INSTALL_VERSION
  fi
  local message="$2"
  local ref="$3"
  local changeset="$4"
  local avoid_ref="$5"

  NVM_DIR=$(mktemp -d) || die 'Unable to create temporary directory'
  NVM_DIR="$NVM_DIR/clone"

  # Ensure it clones the repository for non existing directory
  test_step "Clones repo $message"
  install_nvm_from_git
  test_install_data "$(get_head_ref)" "$(get_head_changeset)" "$message" "$ref" "$changeset" "$avoid_ref"
  rm -rf "$NVM_DIR"

  # Ensure it initializes the repository for an empty existing repository
  mkdir -p "$NVM_DIR" || die 'Unable to create directory'
  test_step "Initialize repo $message"
  install_nvm_from_git
  test_install_data "$(get_head_ref)" "$(get_head_changeset)" "$message" "$ref" "$changeset" "$avoid_ref"
  rm -rf "$NVM_DIR"

  # Ensure it updates the repository for an existing git repository
  git clone "$(nvm_source "git")" -b "v0.36.0" --depth=2 "$NVM_DIR" || die 'Unable to clone repository'
  step_to_previous_changeset
  test_step "Updates repo $message"
  install_nvm_from_git
  test_install_data "$(get_head_ref)" "$(get_head_changeset)" "$message" "$ref" "$changeset" "$avoid_ref"
  rm -rf "$NVM_DIR"
}

# Handle latest version
test_install "" "latest version" "$(nvm_latest_version)"

# Handle given changeset
changeset="3abb98124e8d30c9652976c9d34a7380036083b5"
test_install "$changeset" "with changeset $changeset" "" "$changeset" "$(nvm_latest_version)"

# Handle given tag
test_install "v0.37.0" "version v0.37.0" "v0.37.0" "4054bd70cedb9998015c2d8cc468c818c7d2f57d" "$(nvm_latest_version)"

# Handle given ref
test_install "refs/pull/2397/head" "with refs/pull/2397/head" "" "9849bf494d50e74aa810451fb1f83208b0092dd6" "$(nvm_latest_version)"
test_install "master" "master" "" "" "$(nvm_latest_version)"

cleanup
