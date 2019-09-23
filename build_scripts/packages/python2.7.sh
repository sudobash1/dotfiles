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
)
VERSION=2.7.16
export SRC=https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz

STATIC=false

do_check() {
  [[ -x "$PREFIX/bin/python2.7" ]] || return 1
}
