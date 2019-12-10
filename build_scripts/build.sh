#!/bin/bash

set -e

cd "$(dirname "$0")"

PKGDIR=$(pwd)/packages
LIBDIR=$(pwd)/lib
export PKGDIR LIBDIR

if [[ -z "$1" ]]; then
  echo "Usage: $(basename "$0") package-name"
  exit 1
fi

unset DEP_BUILD # paranoia
unset LIB_BUILD # paranoia

source "$LIBDIR/common.sh"

export PATH="$PREFIX/bin:$LIB_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$LIB_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LIB_PREFIX/lib:$LD_LIBRARY_PATH"

case $(basename "$0") in
  build.sh)
    function process() { "$LIBDIR/build.sh" "$1"; }
    ;;
  uninstall.sh)
    function process() { uninstall "$1" || true; }
    extra_vars=()
    export VERBOSE=1
    ;;
esac

verify_settings

while [[ $# -ne 0 ]]; do
  process "$1"
  shift
done
