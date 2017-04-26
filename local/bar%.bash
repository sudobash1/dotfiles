[[ $- == *i* && $HOSTNAME == bar1 ]] && echo -e "\n\n  =======  PLEASE SSH TO ANOTHER BAR  =======\n\n"

alias goto_bar_repo='cd ~/${HOSTNAME}_repos'
export PATH="$HOME/repos/tg/tg/install/bin:$HOME/bin:/home/srobinson/build/tau-2.26.1/x86_64/bin:$PATH"

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

export HOME=/lustre/home/srobinson

source $DOTFILES_REPO/local/xstg.bash
