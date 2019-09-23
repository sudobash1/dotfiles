export DEPENDS=(
  "python3.7"
)
export SRC=https://bootstrap.pypa.io/get-pip.py

do_check() {
  [[ -x "$PREFIX/bin/pip3.7" ]] || return 1
}
do_fetch() {
  download "$SRC"
}
do_build() { true; }
do_install() {
  $PREFIX/bin/python3.7 get-pip.py
}
