#!/bin/bash

# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
#
# MichiK <michik@michik.net> wrote this file. As long as you retain this
# notice you can do whatever you want with this stuff. If we meet some day,
# and you think this stuff is worth it, you can buy me a beer in return.
# ----------------------------------------------------------------------------

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
