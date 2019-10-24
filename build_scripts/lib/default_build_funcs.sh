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
def_autoconf() {
  [[ -x ./configure ]] || ./autogen.sh
  if istrue "$IS_LIB"; then
    prefix="$LIB_PREFIX"
  else
    prefix="$PREFIX"
  fi
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
  ./configure --prefix="$(printf '%q' "$prefix")" "${CONFIGURE_FLAGS[@]}"
}
def_make() {
  if [[ -n $MAKE_J ]]; then
    make "$MAKE_J"
  else
    make
  fi
}
def_do_build() {
  def_autoconf
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
