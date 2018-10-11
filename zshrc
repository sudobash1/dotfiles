# If not running interactively, don't do anything
[[ -o interactive ]] || return

source ~/.shrc

# ------------------- OH MY ZSH ------------------- {{{

# Path to your oh-my-zsh installation.
export ZSH=$DOTFILES_REPO/oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="kphoen"
#ZSH_THEME="kafeitu"
#ZSH_THEME="dpoggi"
#ZSH_THEME="gentoo"
ZSH_THEME="sudobash"
#ZSH_THEME="robbyrussell"
#ZSH_THEME="daveverwer"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
ZSH_CUSTOM=$DOTFILES_REPO/zsh

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# }}}

# ------------------- Basic settings ------------------- {{{

# Allow ** globs and more
# See man zshexpn section `FILENAME GENERATION'
setopt extendedglob

# pound sign in interactive prompt
setopt interactivecomments

# ------------------- History ------------------- {{{

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt nosharehistory
#setopt sharehistory

# Add timestamp information to history
#setopt extendedhistory

# }}}

# }}}

# ------------------- Key Binding ------------------- {{{

# Shift-tab to go back in completion
bindkey '^[[Z' reverse-menu-complete

# Make home and end work as expected...
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

# Make Ctrl-R behave like bash
bindkey '^R' history-incremental-search-backward

# }}}


# Execute the local zshrc (if exists)
[[ -f $HOME/.zshrc.local.zsh ]] && source $HOME/.zshrc.local.zsh

# vim: fdm=marker foldlevel=0
