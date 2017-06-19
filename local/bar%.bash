[[ $- == *i* && $HOSTNAME == bar1 ]] && echo -e "\n\n  =======  PLEASE SSH TO ANOTHER BAR  =======\n\n"

[[ $HOSTNAME != bar36 ]] && export HOME=/lustre/home/srobinson

function __repo_base() {
  (while true; do
    ls apps/.git &>/dev/null && { pwd; return 0; }
    cd ..
    [[ $(pwd) == "/" ]] && { echo "$HOME/${HOSTNAME}_repos"; return 1; }
  done)
}

alias goto_bar_repo='cd ~/${HOSTNAME}_repos'

if [[ $HOSTNAME == bar36 ]]; then
  export PATH="\
$HOME/repos/tg/tg/install/bin:\
$HOME/bin:\
$PATH:\
/usr/mpi/gcc/openmpi-1.10.3a1/bin:\
$HOME/.local/opt/compilers_and_libraries_2017.0.098/linux/mpi/intel64/bin:\
$HOME/.local/opt/compilers_and_libraries_2017.0.098/linux/bin/intel64"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/opt/compilers_and_libraries_2017.0.098/linux/mpi/intel64/lib:$HOME/.local/opt/lib/intel64_lin"
else
  export PATH="\
$HOME/repos/tg/tg/install/bin:\
$HOME/bin:/home/srobinson/build/tau-2.26.1/x86_64/bin:\
/opt/intel/tools-2017/bin:\
/opt/intel/tools-2017/compilers_and_libraries_2017.0.098/linux/mpi/intel64/bin:\
$PATH"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/intel/tools-2017/lib/intel64_lin"
fi

alias clustermyps=$'for i in {1..32} 36;do echo -en "bar$i\t";ssh bar$i -qt \'ps ux|awk "END{print NR-5}"\';done'
alias clusterwho=$'for i in {1..32} 36;do echo -en "\nbar$i\t";ssh bar$i -qt \'ps -Gxstack -ouser|awk -vORS=, \'\\\'\'/^[^U]/{users[$1]}END{for(x in users)print x}\'\\\';done;echo'

alias ocrenv=$'OCR_INSTALL=$(__repo_base)/ocr/ocr/install LD_LIBRARY_PATH=$(__repo_base)/ocr/ocr/install/lib:$(__repo_base)/apps/apps/libs/install/x86/lib:$LD_LIBRARY_PATH'
alias ocrmpi=$'OCR_CONFIG=install/x86-phi-mpi/generated.cfg ocrenv mpirun -host $HOSTNAME'

function config_gen() {
  extra_args="--remove-destination"
  grep -q -- '--output' <<< "$@" || extra_args="$extra_args --output generated.cfg"
  grep -q -- '--target' <<< "$@" || extra_args="$extra_args --target x86"
  grep -q -- '--guid' <<< "$@" || extra_args="$extra_args --guid COUNTED_MAP"
  grep -q -- '--threads' <<< "$@" || extra_args="$extra_args --threads 4"
  eval "$(__repo_base)/ocr/ocr/install/share/ocr/scripts/Configs/config-generator.py $extra_args $@"
}

alias config_gen_x86=$'config_gen --output install/x86/generated.cfg --target x86'
alias config_gen_x86_mpi=$'config_gen --output install/x86-mpi/generated.cfg --target mpi'

alias config_gen_phi=$'config_gen --output install/x86-phi/generated.cfg --target x86'
alias config_gen_phi_mpi=$'config_gen --output install/x86-phi-mpi/generated.cfg --target mpi'

alias analyzeProfile=$'$(__repo_base)/ocr/ocr/scripts/Profiler/analyzeProfile.py'
alias summaryProfile=$"analyzeProfile -t'*' -s | sed -n -e '/TOTAL/,\$p' | sed -e 's/^[/\\]/ /'"

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# cd variables
shopt -s cdable_vars

export repos="$HOME/${HOSTNAME}_repos"
export hpcg="$HOME/${HOSTNAME}_repos/apps/apps/hpcg/refactored/ocr/intel-Eager"
export comd="$HOME/${HOSTNAME}_repos/apps/apps/CoMD/refactored/ocr/intel-chandra-tiled"
export rsbench="$HOME/${HOSTNAME}_repos/apps/apps/RSBench/refactored/ocr/intel-sharedDB"

alias goto_bar_repo='cd $repos'


# auto source the apps_env.bash
if [[ -e "$repos/apps/apps/apps_env.bash" ]]; then
  source "$repos/apps/apps/apps_env.bash" > /dev/null
fi
