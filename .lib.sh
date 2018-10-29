#!/bin/bash

# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
#
# MichiK <michik@michik.net> wrote this file. As long as you retain this
# notice you can do whatever you want with this stuff. If we meet some day,
# and you think this stuff is worth it, you can buy me a beer in return.
# ----------------------------------------------------------------------------

set -e

# A simple error handler that displays the line number and file name and an
# optional error message before existing the script.
#
# The function accepts a second optional parameter that gives the stack
# position to print out (in case we are validating some input and want the
# line that called that validation function instead of the error handler).
throw() {
  [ -z "$1" ] && err="unknown error" || err="$1"
  frame=$2
  read line file <<< "$(caller ${frame-0})"
  echo -e "\e[91mERROR in ${file} line ${line}: ${err}\e[0m"
  exit 1
}

# Check for all the tools we need and throw an error if they are not available.
[ -x "/usr/bin/diff" ] || throw "diff not found, please install diffutils"
[ -x "/usr/bin/find" ] || throw "dinf not found, please install findutils"

# Set the source and destination directory. The source directory is obviously
# the directory where the install script is in whereas the destination
# directory defaults to the current user's home directory.
#
# A different destination directory can given as a command line parameter.
sourcedir="$(dirname "$0")"
if [ -n "$1" ] ; then
  destdir="$1"
else
  destdir="$HOME"
fi

# Validate the destination directory. It either has to be a directory and the
# user needs write permissions to it, or, if it does not exist yet, the script
# will try to create it.
if [ -d "${destdir}" ] ; then
  [ -w "${destdir}" ] || throw "destination directory not writable"
else
  echo -n "Destination directory ${destdir} does not exist, creating it... "
  if mkdir -p "${destdir}" 2> /dev/null ; then
    echo "done!"
  else
    echo "failed!"
    throw "could not create destination directory"
  fi  
fi

# This is the main function used to install dotfiles where they belong. It
# takes three arguments, one of which is optional:
#
# $1: the source file relative to the directory of the dotfile repository
# $2: the target file relative to the target directory (usually $HOME)
# $3: the permissions to set on the target file (optional, defaults to 0644)
#
# The function checks if the file to create exists. If yes, the files are
# compared and the user is asked what to do. The file can either be kept or
# it can be overwritten. If diff is installed, a diff can be shown.
install_dotfile() {
  [ -z "$1" ] && throw "no source file name given" || src="$1"
  [ ! -f "${src}" ] && throw "${src} does not exist" 1
  [ -z "$2" ] && throw "no target file name given" || tgt="${destdir}/$2"
  [ -z "$3" ] && perms="0644" || perms="$3"
  echo -n "Installing ${src} into ${tgt}... "
  if [ -e "${tgt}" ] ; then
    if [ ! -f "${tgt}" ] ; then
      echo
      throw "${tgt} exists but is not a file"
    fi
    if cmp -s "${src}" "${tgt}" ; then
      echo "skipping!"
    else
      echo "exists!"
      while true ; do
        echo -n "What do you want to do? [s]kip/[o]verwrite/[d]iff/[q]uit: "
        read -p "" res
        case "${res}" in
          [qQ])
            echo "Aborted."
            exit 130
            ;;
          [oO])
            cp "${src}" "${tgt}"
            chmod "${perms}" "${tgt}"
            break
            ;;
          [sS])
            break
            ;;
          [dD])
            echo
            if [ -x "/usr/bin/colordiff" ] ; then
              colordiff -u "${src}" "${tgt}" || true
            else
              diff -u "${src}" "${tgt}" || true
            fi
            ;;
          *)
            echo "Please enter s, o, d or a."
            ;;
        esac
      done
    fi
  else
    mkdir -p $(dirname "${tgt}")
    cp "${src}" "${tgt}"
    chmod "${perms}" "${tgt}"
    echo "done!"
  fi
}

# vim: set ts=2 sw=2 expandtab:
