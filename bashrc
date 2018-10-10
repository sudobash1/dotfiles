# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

source ~/.shrc

# ------------------- Basic settings ------------------- {{{

PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# We want vim! We want vim!
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# Use vi keybindings
set -o vi
# Recheck the window size after every command
shopt -s checkwinsize
# Append (don't overwrite) history
shopt -s histappend
# Allow ** globs
shopt -s globstar

# ------------------- History ------------------- {{{

export HISTCONTROL=ignoredup # Don't put duplicate lines in the history
shopt -s histappend # Append instead of overwriting the history file
export HISTSIZE=1000
export HISTFILESIZE=2000

# }}}

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
source $DOTFILES_REPO/bash/bash_completion_tmux.sh

# }}}

# ------------------- Aliases & Functions ------------------- {{{

if [[ ${BASH_VERSINFO[0]} > 4 || (${BASH_VERSINFO[0]} == 4 && ${BASH_VERSINFO[1]} > 0) ]]; then

function __bashrc__tablesort() { #{{{
  if [[ ! $__BASHRC__TABLESORT_FN || ! $__BASHRC__TABLESORT_SEP ]]; then
    echo "Do not call __bashrc__tablesort directly!"
    return 1
  fi
  if [[ $# != 1 && $# != 2 ]]; then
    echo "Usage: $__BASHRC__TABLESORT_FN column_name/num [file]"
    echo
    echo "if file is unspecified or -, the stdin is used"
    return 1
  fi
  if [[ $# == 2 && $2 != "-" ]]; then
    if [[ ! -r $2 ]]; then
      echo "Unable to read file $2"
      return
    fi
    exec {FD}<$2
  else
    exec {FD}<&0
  fi

  IFS="" read header <&$FD
  col=""
  if [[ $1 =~ ^[0-9]+$ ]]; then
    col=$1
  elif [[ $header == *"$__BASHRC__TABLESORT_SEP$1$__BASHRC__TABLESORT_SEP"* || \
          $header == "$1$__BASHRC__TABLESORT_SEP"* || \
          $header == *"$__BASHRC__TABLESORT_SEP$1" || \
          $header == "$1" \
       ]]; then
    col=$(printf -- "$header" | awk -F "$__BASHRC__TABLESORT_SEP" $"{for (i=1; i<=NF; i++) {if (\$i == \"$1\") {print i; exit} }}")
  fi

  if [[ ! $col =~ ^[0-9]+$ ]]; then
    echo "Unknown header '$1'"
    exec {FD}<&-
    return 1
  fi

  printf -- "$header\n"
  sort -t "$__BASHRC__TABLESORT_SEP" -k $col -n <&$FD
  exec {FD}<&-
} #}}}

alias csvsort=$'__BASHRC__TABLESORT_SEP=\',\' __BASHRC__TABLESORT_FN=\'csvsort\' __bashrc__tablesort'
alias tsvsort=$'__BASHRC__TABLESORT_SEP=\'\t\' __BASHRC__TABLESORT_FN=\'tsvsort\' __bashrc__tablesort'

else

alias csvsort=$'echo "csvsort is not supported for bash < 4.1"#'
alias csvsort=$'echo "tsvsort is not supported for bash < 4.1"#'

fi

# TODO: should the below line go in shrc?
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

unset USE_COLOR

# }}}

# Execute the local bashrc (if exists)
[[ -f $HOME/.bashrc.local.bash ]] && source $HOME/.bashrc.local.bash

# vim: fdm=marker foldlevel=0
