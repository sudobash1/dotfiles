alias r='pkill -9 "gdb|xstg|fsim" && fg ; stty sane'
alias k='pkill -9 "gdb|xstg|fsim|pmi_proxy"'
alias err_check='grep -iE "error|fail|abend|inval|unali" *'

# cd variables
shopt -s cdable_vars

export repos=${repos-"$HOME/repos/intel"}
export apps="$repos/apps/apps/"
export ocr="$repos/ocr/ocr/"
export tg="$repos/tg/tg/"
export hpcg="$apps/hpcg/refactored/ocr/intel-Eager"
export comd="$apps/CoMD/refactored/ocr/intel-chandra-tiled"
export rsbench="$apps/RSBench/refactored/ocr/intel-sharedDB"
export libs="$apps/libs/src"
export newlib="$libs/newlib/newlib-2.1.0/newlib/libc/sys/tgr"
export mpi="$libs/libmpich/mpich-3.2/src"

# auto source the apps_env.bash
if [[ -e "$apps/apps_env.bash" ]]; then
  source "$apps/apps_env.bash" > /dev/null
fi
