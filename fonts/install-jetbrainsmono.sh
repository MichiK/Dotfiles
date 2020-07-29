#!/bin/bash

# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
#
# MichiK <michik@michik.net> wrote this file. As long as you retain this
# notice you can do whatever you want with this stuff. If we meet some day,
# and you think this stuff is worth it, you can buy me a beer in return.
# ----------------------------------------------------------------------------

set -e

echo -n "Installing JetBrains Mono... "

if [ ! -x "/usr/bin/curl" ] ; then
  echo "failed"
  warn "curl not found, font installation aborted"
elif [ ! -x "/usr/bin/unzip" ] ; then
  echo "failed"
  warn "unzip not found, font installation aborted"
else
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
fi

# vim: set ts=2 sw=2 expandtab:
