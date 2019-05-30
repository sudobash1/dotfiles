export TOOLCHAIN_PATH_ARMV7=$HOME/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf
export LANG=en_US.UTF-8
function doinit() {
  if [ -n "$ZSH_VERSION" ]; then
    local SBR_SETOPT_SHWORDSPLIT=$(setopt | grep '^shwordsplit$')
    setopt shwordsplit
  fi
  cd ~/tisdk/build/
  . conf/setenv
  if [ -n "$ZSH_VERSION" ]; then
    rehash
    if [ -z "$SBR_SETOPT_SHWORDSPLIT" ]; then
      unsetopt shwordsplit
    fi
  fi
}
