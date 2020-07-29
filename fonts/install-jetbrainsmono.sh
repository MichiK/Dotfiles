#!/bin/bash

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
