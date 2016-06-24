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
