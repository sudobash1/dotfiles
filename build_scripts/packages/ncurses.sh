DEPENDS=(
  pkg-config
  automake
  gcc
  make
)
IS_LIB=yes
VERSION=6.1
SRC="ftp://ftp.invisible-island.net/ncurses/ncurses-${VERSION}.tar.gz"
CONFIGURE_FLAGS=(
  --with-shared
  --with-normal
  --with-cxx-binding
  --with-cxx-shared
  --without-ada
  --without-debug
  --enable-widec
  --enable-pc-files
  --with-pkg-config-libdir="$PREFIX/lib/pkgconfig"
)

do_install() {
  def_do_install
  # Ncurses adds a 'w' to the end of every name becase of --with-widec, but
  # most pkg-config searches will just look for ncurses. Use symlinks to get
  # around this.
  for l in ncurses ncurses++ form menu panel; do
    ln -s "$PREFIX/lib/pkgconfig/${l}w.pc" "$LIB_PREFIX/lib/pkgconfig/${l}.pc"
  done
}
