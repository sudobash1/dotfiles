DEPENDS=(
  pkg-config
  automake
  make
  gcc
)
VERSION=5.2.4
IS_LIB=yes
SRC="https://tukaani.org/xz/xz-${VERSION}.tar.gz"

do_check() {
  library_exists liblzma "$VERSION"
  command_exists xz
}
