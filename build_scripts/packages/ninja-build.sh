export DEPENDS=(
  "gcc"
  "python2.7"
)
VERSION=1.9.0
export SRC=https://github.com/ninja-build/ninja/archive/v${VERSION}.tar.gz

do_check() {
  command_exists ninja
}
do_build() {
  python configure.py --bootstrap
}
do_install() {
  install -m 755 ninja "$PREFIX/bin/"
}
