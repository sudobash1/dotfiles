#!/bin/bash

export FROM_PKGNAME="$PKGNAME"

export NO_CHECK=0
export VERSION=""
export IS_LIB=0
export SRC=""
export DEPENDS=()
export LDEPENDS=()
export CONFIGURE_FLAGS=""
export STATIC=1
export CFLAGS=""
export LDFLAGS=""

export PKGNAME="$1"
export PKGSCRIPT="$PKGDIR/$PKGNAME.sh"

source "$LIBDIR/common.sh"

# Setup default functions
do_fetch() {
  if [[ -z "$SRC" ]]; then
    error "\$SRC is undefined in $PKGNAME"
    return 1
  fi
  download_extract "$SRC"
}
do_patch() {
  for p in "$PKGDIR"/patches/"$PKGNAME"_*.patch; do
    [[ ! -f $p ]] && continue
    verbose "Applying $p"
    patch -p1 < "$p"
  done
}
do_build() {
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
  if [[ -n $MAKE_J ]]; then
    make "$MAKE_J"
  else
    make
  fi
}
do_install() {
  make install
}
do_check() {
  istrue "$NO_CHECK" && return 0
  if istrue "$IS_LIB" || istrue "$LIB_BUILD"; then
    local vv="VERSION_$PKGNAME"
    library_exists "$PKGNAME" "${VERSION-${!vv}}"
  else
    command_exists "$PKGNAME"
  fi
}

if [[ ! -f "$PKGSCRIPT" ]]; then
  if istrue "$DEP_BUILD"; then
    try do_check || exit 1
    exit
  else
    error "Cannot find build script for $PKGNAME"
    error "Expected it at $PKGSCRIPT"
    exit 1
  fi
fi

source "$PKGSCRIPT"

for dep in "${DEPENDS[@]}"; do
  verbose "Checking dependancy $dep"
  DEP_BUILD=1 LIB_BUILD=0 "$LIBDIR/build.sh" "$dep" || exit 1
done

for dep in "${LDEPENDS[@]}"; do
  verbose "Checking library dependancy $dep"
  DEP_BUILD=1 LIB_BUILD=1 "$LIBDIR/build.sh" "$dep" || exit 1
done

if check_hash "$PKGSCRIPT"; then
  if istrue "$DEP_BUILD"; then
    verbose "Dependency satisfied (Already built)"
  else
    verbose "Skipping already built $PKGNAME"
  fi
  exit
fi

# Force rebuild of parent (if any)
if [[ -n "$FROM_PKGNAME" ]] && check_hash "$FROM_PKGNAME"; then
  verbose "Flagging package $FROM_PKGNAME for rebuild"
  remove_hash "$FROM_PKGNAME"
fi

verbose "All dependencies good. Starting build"

(
  # Create and get into package build directory
  cd "$TMPDIR"
  rm -rf "$PKGNAME"
  mkdir "$PKGNAME"
  cd "$PKGNAME"

  verbose "Running ${PKGNAME}.fetch"
  run_function do_fetch
  verbose "Running ${PKGNAME}.patch"
  run_function do_patch
  verbose "Running ${PKGNAME}.build"
  run_function do_build
  verbose "Running ${PKGNAME}.install"
  run_function do_install
  verbose "Running ${PKGNAME}.check"
  run_function do_check
) || exit 1

write_hash "$PKGSCRIPT"
verbose "Finished building $PKGNAME"
if istrue "$DEP_BUILD"; then
  verbose "Dependency satisfied"
fi
