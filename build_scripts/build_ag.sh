#!/bin/bash

# All non-zero exits are fatal
set -e

TMPDIR=${TMPDIR:-$(pwd)/tmp}
PCRE_LIB_URL=${PCRE_LIB_URL:-ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.bz2}
AG_URL=${AG_URL:-https://github.com/ggreer/the_silver_searcher/archive/2.1.0.tar.gz}
PREFIX=${PREFIX:-$HOME/.local}
DO_INSTALL=${DO_INSTALL:-0}
MAKE_J=${MAKE_J:-}

function verify_settings {
  for setting in TMPDIR PCRE_LIB_URL AG_URL PREFIX DO_INSTALL MAKE_J; do
    echo "${setting} = ${!setting}"
  done | column -t

  ans=""
  while [[ $ans != "y" && $ans != "n" ]]; do
    read -N 1 -p "Are these settings correct [y/n]? " ans
    echo
    ans=$(tr A-Z a-z <<< $ans)
  done
  [[ $ans != "y" ]] && exit 1
  echo "Starting build"
}

function download {
  cd "$TMPDIR"
  url=${!1}

  archive=$(basename "$url")
  dir=$2$(awk -F '\\.tar' '{print $1}' <<< $archive)

  [[ -e $dir ]] && { echo "'$dir' already exsts in \$TMPDIR"; exit 1;}

  wget "$url" || { echo "Unable to download '$url'"; exit 1;}

  echo "Extracting archive ($archive)"
  tar -xf "$archive"
  cd "$dir"
}

verify_settings

orig_dir="$(pwd)"
mkdir -p "$TMPDIR" || { echo "Connot create dir: '$TMPDIR'"; exit 1;}
cd "$TMPDIR" || { echo "Connot enter dir: '$TMPDIR'"; exit 1;}
TMPDIR="$(pwd)"
tmproot="$TMPDIR/tmproot"

# Build PCRE
echo "Building PCRE"
download PCRE_LIB_URL
./configure --prefix="$tmproot"  --enable-jit --enable-unicode-properties
make ${MAKE_J}
make install

#Build AG
echo "Building AG"
download AG_URL the_silver_searcher-
aclocal && autoconf && autoheader && automake --add-missing
./configure PCRE_CFLAGS="-I '$tmproot/include'" PCRE_LIBS="-L '$tmproot/lib' -Wl,-Bstatic -lpcre -Wl,-Bdynamic"
make ${MAKE_J}
[[ $DO_INSTALL != "0" ]] && make install
cp ag $orig_dir

echo "Done"
