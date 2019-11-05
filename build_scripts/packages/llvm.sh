DEPENDS=(
  gcc
  cmake
  make
)
LDEPENDS=(
  zlib
)

VERSION="9.0.0"
SRC=(
  "http://releases.llvm.org/9.0.0/cfe-${VERSION}.src.tar.xz"
  "http://releases.llvm.org/9.0.0/llvm-${VERSION}.src.tar.xz"
)
STATIC=false

do_fetch() {
  clang_url="${SRC[0]}"
  download "$clang_url"
  clang_archive="$(basename "$clang_url")"
  tar xf "$clang_archive"
  mv "$(tar tf "$clang_archive" | head -n1)" clang
  download_extract "${SRC[1]}"
}

CONFIGURE_FLAGS=(
  -DLLVM_ENABLE_PROJECTS=clang
  -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=on
)
