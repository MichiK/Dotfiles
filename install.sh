#!/bin/bash

set -e

. lib.sh

# Cycle through all subdirectories and look for an install.sh script there.
# These scripts do the actual work of installing the dotfiles in the respective
# directory.
#
# This keeps the structure modular and the individual scripts small and clean.
for dir in $(find "${sourcedir}" -mindepth 1 -maxdepth 1 -type d) ; do
  dir="$(basename "${dir}")"
  [ "${dir}" = ".git" ] && continue
  echo -n "Descending into ${dir}... "
  if [ -x "${dir}/install-${dir}.sh" ] ; then
    echo
    (cd "${dir}" ; . "install-${dir}.sh")
  else
    echo "skipping!"
  fi
done

echo -e "\e[92mAll dotfiles installed succesfully!\e[0m"

# vim: set ts=2 sw=2 expandtab:
