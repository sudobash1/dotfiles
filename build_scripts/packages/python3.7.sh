export DEPENDS=(
  "make"
  "gcc"
  "gettext"
  "libtool"
  "autoconf"
  "automake"
  "pkg-config"
)
export LDEPENDS=(
  "libffi"
  "openssl"
)
VERSION=3.7.4
export SRC=https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz

STATIC=false

do_check() {
  [[ -x "$PREFIX/bin/python3.7" ]] || return 1
}
