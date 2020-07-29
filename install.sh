#!/bin/bash

set -e

. "$(dirname "$0")/lib.sh"

# Cycle through all subdirectories and look for an install.sh script there.
# These scripts do the actual work of installing the dotfiles in the respective
# directory.
#
# This keeps the structure modular and the individual scripts small and clean.
for dir in $(find "${sourcedir}" -mindepth 1 -maxdepth 1 -type d) ; do
  dir="$(basename "${dir}")"
  [ "${sourdedir}/${dir}" = ".git" ] && continue
  echo -n "Descending into ${dir}... "
  if [ -f "${sourcedir}/${dir}/install-${dir}.sh" ] ; then
    echo
    (cd "${sourcedir}/${dir}" ; . "install-${dir}.sh")
  else
    echo "skipping!"
  fi
done

if [ -f "${warnings_file}" -a ! -s "${warnings_file}" ] ; then
  echo -e "\e[92mAll dotfiles installed succesfully!\e[0m"
else
  echo -e "\e[91mDotfiles installed with warnings!\e[0m"
  exit 1
fi

# vim: set ts=2 sw=2 expandtab:
