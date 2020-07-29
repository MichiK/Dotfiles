#!/bin/bash

install_dotfile zshrc .zshrc

echo "Installing Oh My Zsh... "

clone_git_repo https://github.com/ohmyzsh/ohmyzsh .oh-my-zsh

if [ -d "${destdir}/.oh-my-zsh/custom" ] ; then
  install_dotfile theme .oh-my-zsh/custom/themes/michik.zsh-theme
  clone_git_repo https://github.com/cedi/meaningful-error-codes \
    .oh-my-zsh/custom/plugins/meaningful-error-codes
  clone_git_repo https://github.com/zsh-users/zsh-autosuggestions \
    .oh-my-zsh/custom/plugins/zsh-autosuggestions
  clone_git_repo https://github.com/zsh-users/zsh-syntax-highlighting \
    .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
  warn "Oh My Zsh missing, plugins not installed!"
fi

# vim: set ts=2 sw=2 expandtab:
