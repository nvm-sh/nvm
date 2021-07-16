#!/bin/sh

cleanup () {
  unset -f safe_type die cleanup
}
die () { echo "$@" ; cleanup ; exit 1; }

safe_type() {
  type "$1"
}

# precondition: the names should be unset
! safe_type nvm_do_install || die 'nvm_do_install is still available'
! safe_type nvm_has || die 'nvm_has is still available'
! safe_type nvm_download || die 'nvm_download is still available'
! safe_type install_nvm_as_script || die 'install_nvm_as_script is still available'
! safe_type install_nvm_from_git || die 'install_nvm_from_git is still available'
! safe_type nvm_reset || die 'nvm_reset is still available'
! safe_type nvm_detect_profile || die 'nvm_detect_profile is still available'

NVM_ENV=testing \. ../../install.sh

# Check nvm_reset exists
safe_type nvm_reset || die 'nvm_reset is not available'

# Apply nvm_reset
nvm_reset || die 'nvm_reset failed'

# The names should be unset
! safe_type nvm_do_install || die 'nvm_do_install is still available'
! safe_type nvm_has || die 'nvm_has is still available'
! safe_type nvm_download || die 'nvm_download is still available'
! safe_type install_nvm_as_script || die 'install_nvm_as_script is still available'
! safe_type install_nvm_from_git || die 'install_nvm_from_git is still available'
! safe_type nvm_reset || die 'nvm_reset is still available'
! safe_type nvm_detect_profile || die 'nvm_detect_profile is still available'

cleanup
