[[ $- == *i* && $HOSTNAME == bar1 ]] && echo -e "\n\n  =======  PLEASE SSH TO ANOTHER BAR  =======\n\n"

alias goto_bar_repo='cd ~/${HOSTNAME}_repos'
export PATH="$HOME/repos/tg/tg/install/bin:$HOME/bin:/home/srobinson/build/tau-2.26.1/x86_64/bin:$PATH"

alias clustermyps=$'for i in {1..32} 36;do echo -en "bar$i\t";ssh bar$i -qt \'ps ux|awk "END{print NR-5}"\';done'
alias clusterwho=$'for i in {1..32} 36;do echo -en "\nbar$i\t";ssh bar$i -qt \'ps -Gxstack -ouser|awk -vORS=, \'\\\'\'/^[^U]/{users[$1]}END{for(x in users)print x}\'\\\';done;echo'

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

export HOME=/lustre/home/srobinson

source $DOTFILES_REPO/local/xstg.bash
