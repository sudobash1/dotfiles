alias r='pkill -9 "gdb|xstg|fsim" && fg ; stty sane'
alias k='pkill -9 "gdb|xstg|fsim|pmi_proxy"'
alias err_check='grep -iE "error|fail|abend|inval|unali" *'

# cd variables
shopt -s cdable_vars

function set_repos() {
  export repos=$({ cd $1 2>/dev/null && pwd; } || echo ${repos-"$HOME/repos/intel"} )
  export apps="$repos/apps/apps"
  export ocr="$repos/ocr/ocr"
  export tg="$repos/tg/tg"
  export hpcg="$apps/hpcg/refactored/ocr/intel-Eager"
  export comd="$apps/CoMD/refactored/ocr/intel-chandra-tiled"
  export rsbench="$apps/RSBench/refactored/ocr/intel-sharedDB"
  export libs="$apps/libs/src"
  export newlib="$libs/newlib/newlib-2.1.0/newlib/libc/sys/tgr"
  export mpi="$libs/libmpich/mpich-3.2/src"
  export legacy="$apps/legacy/tg-xe"
  export regtest="$apps/tools/regression_tests"
  export fsim="$tg/fsim"

  export PATH=$(echo $PATH | awk -v RS=: -v ORS=: '/tg\/tg\/install\/bin\/?$/{next} {print}' | tr -d "\n" | sed "s%:*$%:$tg/install/bin%")

  # auto source the apps_env.bash
  if [[ -e "$apps/apps_env.bash" ]]; then
    source "$apps/apps_env.bash" > /dev/null
  fi
}
set_repos ${repos-"$HOME/repos/intel"}

