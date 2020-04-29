#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm_is_merged_node_version '4.0' || die '"nvm_is_merged_node_version 4.0 was not true'
nvm_is_merged_node_version '5.1' || die '"nvm_is_merged_node_version 5.1 was not true'
! nvm_is_merged_node_version '3.99' || die '"nvm_is_merged_node_version 3.99 was not false'
! nvm_is_merged_node_version 'v1.0.0' || die '"nvm_is_merged_node_version v1.0.0" was not false'
