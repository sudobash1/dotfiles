DEPENDS=(
  "pip3.7"
)

do_fetch() { true; }
do_build() { true; }
do_install() {
  "$PREFIX/bin/pip3.7" install compiledb
}
