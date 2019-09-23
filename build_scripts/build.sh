#!/bin/bash

set -e

cd "$(dirname $0)"

export PKGDIR=$(pwd)/packages
export LIBDIR=$(pwd)/lib

if [[ -z "$1" ]]; then
  echo "Usage: $(basename $0) package-name"
fi

unset DEP_BUILD # paranoia
unset LIB_BUILD # paranoia

source "$LIBDIR/common.sh"

export PATH="$PREFIX/bin:$LIB_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$LIB_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

while [[ $# -ne 0 ]]; do
  "$LIBDIR/build.sh" "$1"
  shift
done
