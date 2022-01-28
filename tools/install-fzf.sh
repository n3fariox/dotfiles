#!/bin/bash
set -e
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "################################ Installing fzf ################################"
# I like to install this by copying it out of dotfiles, so that way it's a 
# standalone install as fzf will set up symlinks
mkdir -p ~/.fzf/bin
tar -C ~/.fzf/ -xvf "$THIS_DIR/fzf.tar.gz"
tar -C "$HOME/.fzf/bin" -xvf "$THIS_DIR/tools.tar.gz" "fzf"
"$HOME/.fzf/install" --all
