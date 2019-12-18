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
                  $STATIC_FLAG \
                  $LDFLAGS"
  export CFLAGS="-isystem $(printf '%q' "$PREFIX/include") \
                 $CFLAGS"
}
def_autoconf() {
  [[ -x "./$CONFIGURE_SCRIPT" ]] || ./autogen.sh
  def_confenv
  "./$CONFIGURE_SCRIPT" --prefix="$PREFIX" "${CONFIGURE_FLAGS[@]}"
}
def_cmakeconfig() {
  SRCDIR="$(getdirpath ${SRCDIR:-$(pwd)})"
  BUILDDIR="${BUILDDIR:-./build}"
  def_confenv
  mkdir "$BUILDDIR"
  cd "$BUILDDIR"
  cmake "$SRCDIR" -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -G "${CMAKE_GENERATOR}" \
    "${CONFIGURE_FLAGS[@]}"
}
def_make() {
  multicore_make
}
def_do_build() {
  if istrue "$USE_AUTOCONF"; then
    def_autoconf
  elif istrue "$USE_CMALE"; then
    def_cmakeconfig
  elif [[ -f CMakeLists.txt ]]; then
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
