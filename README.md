# dotfiles
Dem Dotfiles Dough

Repo containing my dotfiles, as well as other helpful scripts/techniques I've
picked up over the years.

## tmux

Simple tmux config that sets up some easy key-binds, and uses as simple, yet
informative status line.

`ctrl-up` swaps into "remote mode" where all keybinds are passed into a nested
tmux session. Don't go more than 1 deep...you'll never come back...

Uses a stupidly gross heredoc bash command to display your current ip addresses
and ignore:

- docker bridges
- libvirt bridges

## bash

KISS. Less is more.

Utilizes the Git PS1 support. PS1 prompt on a newline FTW.

Shruggie alias is a must.

Make sure we always use buildkit.
