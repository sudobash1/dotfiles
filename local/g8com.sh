export LANG=en_US.UTF-8

function __get_machine() {
  grep '^\s*MACHINE\s*?\??\?=\s*".*"' ~/poky/build/conf/local.conf | \
    perl -pe 's/.*?["'"'"']([^"'"'"']*).*/\1/'
}

function gen_env() {
  local machine=$(__get_machine | tr - _)
  export build="$HOME/poky/build"
  export images="$build/tmp/deploy/images/$(__get_machine)"
  export ipk="$build/tmp/deploy/ipk/$machine"
  export ipkc="$build/tmp/deploy/ipk/cortexa5hf-neon"
  export ipka="$build/tmp/deploy/ipk/all"
  export builds="$build/tmp/work/${machine}-poky-linux-gnueabi"
  export buildsc="$build/tmp/work/cortexa5hf-neon-poky-linux-gnueabi"
  export linux_root="$builds/linux-at91/$(ls -t $builds/linux-at91/ 2>/dev/null | head -n1)"
  export linux="$linux_root/git"
  export dts="$linux/arch/arm/boot/dts"
  export vmlinux="$linux_root/build/vmlinux"
}

gen_env

alias linuxline='addr2line -e "$vmlinux" -f'
