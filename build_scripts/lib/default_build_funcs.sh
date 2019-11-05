# FETCH
def_do_fetch() {
  if [[ -z "$SRC" ]]; then
    error "\$SRC is undefined in $PKGNAME"
    return 1
  fi
  download_extract "$SRC"
}

# PATCH
def_do_patch() {
  for p in "$PKGDIR"/patches/"$PKGNAME"_*.patch; do
    [[ ! -f $p ]] && continue
    verbose "Applying $p"
    patch -p1 < "$p"
  done
}

# BUILD
def_confenv() {
  if istrue "$STATIC"; then
    STATIC_FLAG="-static"
  fi
  export LDFLAGS="$(printf '%q' "-L$PREFIX") \
                  $(printf '%q' "-L$LIB_PREFIX") \
                  $STATIC_FLAG \
                  $LDFLAGS"
  export CFLAGS="-isystem $(printf '%q' "$LIB_PREFIX/include") \
                -isystem $(printf '%q' "$PREFIX/include") \
                $CFLAGS"
}
def_autoconf() {
  [[ -x ./configure ]] || ./autogen.sh
  def_confenv
  ./configure --prefix="$(getprefix)" "${CONFIGURE_FLAGS[@]}"
}
def_cmakeconfig() {
  SRCDIR="$(getdirpath ${SRCDIR:-$(pwd)})"
  BUILDDIR="${BUILDDIR:-./build}"
  def_confenv
  mkdir "$BUILDDIR"
  cd "$BUILDDIR"
  cmake "$SRCDIR" -DCMAKE_INSTALL_PREFIX="$(getprefix)" \
    -G "${CMAKE_GENERATOR}" \
    "${CONFIGURE_FLAGS[@]}"
}
def_make() {
  multicore_make
}
def_do_build() {
  if [[ -f CMakeLists.txt ]] || istrue "$USE_CMAKE"; then
    def_cmakeconfig
  else
    def_autoconf
  fi
  def_make
}

# INSTALL
def_do_install() {
  make install
}

# CHECK
def_do_check() {
  istrue "$NO_CHECK" && return 0
  if istrue "$IS_LIB" || istrue "$LIB_BUILD"; then
    local vv="VERSION_$PKGNAME"
    library_exists "$PKGNAME" "${VERSION-${!vv}}"
  else
    command_exists "$PKGNAME"
  fi
}
