#!/bin/bash

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

# A similar function like the error handler that displays a warning message
# instead of a hard error. It does basically the same, but the message looks
# different and the script continues to run.
#
# The fact that a warning has been issued will be written to a temporary file
# that can be queried from install.sh to set a non-zero exit code in case of
# warnings. This hack is needed since the install scripts run in a subshell
# and therefore can not modify the parent environment directly.
warn() {
  [ -z "$1" ] && err="unknown warning" || err="$1"
  frame=$2
  read line file <<< "$(caller ${frame-0})"
  echo -e "\e[93mWARNING in ${file} line ${line}: ${err}\e[0m"
  echo "warned" > "${warnings_file}"
}
warnings_file="$(mktemp)"
cleanup_warnings() {
  rm -f "${warnings_file}"
  trap '' EXIT INT QUIT TERM
}
trap 'cleanup_warnings' EXIT INT QUIT TERM

# Check for all the tools we need and throw an error if they are not available.
[ -x "/usr/bin/curl" ] || throw "curl not found, please install curl"
[ -x "/usr/bin/diff" ] || throw "diff not found, please install diffutils"
[ -x "/usr/bin/find" ] || throw "find not found, please install findutils"
[ -x "/usr/bin/git" ] || throw "git not found, please install git"
[ -x "/usr/bin/unzip" ] || throw "unzip not found, please install unzip"

# Set the source and destination directory. The source directory is obviously
# the directory where the install script is in whereas the destination
# directory defaults to the current user's home directory.
#
# A different destination directory can given as a command line parameter.
sourcedir="$(dirname "$(realpath "$0")")"
if [ -n "$1" ] ; then
  destdir="$(realpath "$1")"
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
              colordiff -u "${tgt}" "${src}" || true
            else
              diff -u "${tgt}" "${src}" || true
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

# This function clones a git repository, e.g. from Github into a given path
# inside the destination directory. It will silently continue if the directory
# already exists, assuming that the repository has been cloned already.
#
# The function takes two arguments:
#
# $1: The repository to clone
# $2: The destination directory (no mkdir -p needed, git will take care of it)
clone_git_repo() {
  [ -z "$1" ] && throw "no git repository given" || repo="$1"
  [ -z "$2" ] && throw "no target directory given" || target="${destdir}/$2"
  echo -n "Cloning $1... "
  if [ -d "${target}" ] ; then
    echo "skipping!"
  else
    stderr=$(mktemp)
    git clone -q "${repo}" "${target}" > /dev/null 2> "${stderr}"
    if [ -s "${stderr}" ] ; then
      echo "failed!"
      warn "$(<"${stderr}")"
    else
      echo "done!"
    fi
    rm -f "${stderr}"
  fi
}

# vim: set ts=2 sw=2 expandtab:
