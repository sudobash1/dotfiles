DEPENDS=(
  make
  gcc
)
VERSION=0.5
SRC="https://github.com/theZiz/aha/archive/${VERSION}.tar.gz"
do_build() {
  def_make
}
do_install() {
  make PREFIX="$(getprefix)" install
}
