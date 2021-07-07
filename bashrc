#!/bin/bash
# Useful utilities
## nicdu - ncurses disk usage

# Useful python libs
## ptpython - fancy interpreter

# The indentation below is purposeful, so you can fold
# and not worry about the curly brace side-effects

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Bash control env vars
HISTCONTROL=ignoreboth
HISTSIZE=
HISTFILESIZE=
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar


# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

################################# BASH PROMPT ##################################
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
    RED="\033[01;31m"
    GREEN="\033[01;32m"
    YELLOW="\033[00;33m"
    BLUE="\033[01;34m"
    RESET="\033[00m"

    if [ -f "/etc/bash_completion.d/git-prompt" ]; then
        # shellcheck disable=SC1091
        . /etc/bash_completion.d/git-prompt
        # shellcheck disable=SC2016
        GIT_PS1='$(__git_ps1 "(%s)")'
    else
        GIT_PS1=""
    fi

    if [ "$color_prompt" = yes ]; then
        PS1="\[$GREEN\]\u@\h\[$RESET\]: \[$YELLOW\]\w\[$RESET\] $GIT_PS1\n\$ "
    else
        PS1="\u@\h: \w $GIT_PS1\n\$ "
    fi
    unset color_prompt RED GREEN YELLOW BLUE RESET GIT_PS1
################################## END PROMPT ##################################
################################### ALIASES ####################################
    alias py3="python3 -m ptpython"
    alias py2="python2 -m ptpython"
    alias grin="grep -rin"
    alias duh="du -hd1"
    alias lash="ls -alh"
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias shrug='echo "¯\_(ツ)_/¯"'
    # enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
################################# END ALIASES ##################################
################################## FUNCTIONS ###################################
    function tmux-update-env() {
        eval "$(tmux show-env -s)"
    }

    function reload() {
        # shellcheck disable=SC1090
        . ~/.bashrc
        echo "Reloaded bashrc"
    }
################################ END FUNCTIONS #################################

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
  fi
fi

# autostart tmux
AUTO_TMUX=0
if [[ -z "$AUTO_TMUX" ]] && which tmux > /dev/null 2>&1; then
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi

export DOCKER_BUILDKIT=1
