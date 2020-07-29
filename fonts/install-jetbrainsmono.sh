#!/bin/bash

set -e

echo -n "Installing JetBrains Mono... "

if [ -d "${destdir}/.fonts/jetbrainsmono" ] ; then
  echo "skipping!"
else
  stdout=$(mktemp)
  stderr=$(mktemp)
  curl -s -S "https://download-cf.jetbrains.com/fonts/JetBrainsMono-2.001.zip" \
    > "${stdout}" 2> "${stderr}" || true
  if [ -s "${stderr}" ] ; then
    echo "failed!"
    warn "$(<"${stderr}")"
  else
    mkdir -p "${destdir}/.fonts/jetbrainsmono/"
    unzip -d "${destdir}/.fonts/jetbrainsmono/" -j "${stdout}" "ttf/*" \
      > /dev/null 2> "${stderr}" || true
    if [ -s "${stderr}" ] ;then
      echo "failed!"
      warn "$(<"${stderr}")"
    fi
  fi
  rm -f "${stdout}" "${stderr}"
  echo "done!"
fi

# vim: set ts=2 sw=2 expandtab:
