export DEPENDS=(
  "make"
  "cmake"
  "gcc"
  "gettext"
  "libtool"
  "autoconf"
  "automake"
  "pkg-config"
  "unzip"
  "ninja-build"
)
VERSION=0.4.2
export SRC=https://github.com/neovim/neovim/archive/v${VERSION}.tar.gz

do_check() {
  command_exists nvim
}
do_build() {
  make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX='$PREFIX'" "${MAKE_J}"
}
