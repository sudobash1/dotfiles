# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# Get the dotfiles repo directory
export DOTFILES_REPO=$(dirname $(find ~/.bashrc -prune -printf "%l\n"))

# ------------------- Basic settings ------------------- {{{

# We want vim! We want vim!
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# Use vi keybindings
set -o vi
# Recheck the window size after every command
shopt -s checkwinsize

export LC_COLLATE="C"

# ------------------- History ------------------- {{{

HISTCONTROL=ignoredup # Don't put duplicate lines in the history
shopt -s histappend # Append instead of overwriting the history file
HISTSIZE=1000
HISTFILESIZE=2000

# }}}

# }}}

# ------------------- less ------------------- {{{

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# }}}

# ------------------- Bash Completions ------------------- {{{

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# My completions
source ~/.dotfiles/bash/bash_completion_tmux.sh

# }}}

# ------------------- Aliases & Functions ------------------- {{{

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

function mantag() {
  man -P "less -p \"^ +$2\"" $1
}

[ -x /usr/bin/dircolors ] && eval "$(dircolors -b)" && alias ls='ls --color=auto'

# }}}

# ------------------- Prompt ------------------- {{{

USE_COLOR=
case "$TERM" in
  *-color) USE_COLOR=1;;
  * ) [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null && USE_COLOR=1
esac

if [ $USE_COLOR ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# }}}

# Execute the local bashrc (if exists)
[[ -f $HOME/.bashrc.local.bash ]] && source $HOME/.bashrc.local.bash

unset USE_COLOR

# vim: fdm=marker foldlevel=0
