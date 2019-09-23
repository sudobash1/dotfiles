DEPENDS=(
  "neovim"
  "pip3.7"
  "pip2.7"
)
NO_CHECK=true

do_fetch() { true; }
do_build() { true; }
do_install() {
  "$PREFIX/bin/pip2.7" install pynvim
  "$PREFIX/bin/pip3.7" install pynvim
}
