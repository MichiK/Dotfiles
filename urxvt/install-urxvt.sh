#!/bin/bash

install_dotfile xresources .Xresources

echo -n "Installing resize-font extension for urxvt... "

if [ -f "${destdir}/.urxvt/ext/resize-font" ] ; then
  echo "skipping!"
else
  if [ -x "/usr/bin/curl" ] ; then
    stdout=$(mktemp)
    stderr=$(mktemp)
    curl -s -S https://raw.githubusercontent.com/simmel/urxvt-resize-font/master/resize-font \
      > "${stdout}" 2> "${stderr}" || true
    if [ -s "${stderr}" ] ; then
      echo "failed!"
      warn "$(<"${stderr}")"
    else
      mkdir -p "${destdir}/.urxvt/ext/"
      cp "${stdout}" "${destdir}/.urxvt/ext/resize-font"
      echo "done!"
    fi
    rm -f "${stdout}" "${stderr}"
  else
    echo "failed!"
    warn "curl not found, resize-font extension not installed"
  fi
fi

# vim: set ts=2 sw=2 expandtab:
