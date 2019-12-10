#!/bin/bash

export FROM_PKGNAME="$PKGNAME"

export NO_CHECK=0
export VERSION=""
export IS_LIB=0
export SRC=""
export SRCDIR="."
export BUILDDIR=""
export DEPENDS=()
export LDEPENDS=()
export CONFIGURE_FLAGS=()
export CONFIGURE_SCRIPT="configure"
export CMAKE_GENERATOR="Unix Makefiles"
export STATIC="DEF_STATIC"
export CFLAGS=""
export LDFLAGS=""
export USE_CMAKE=""
export MULTITHREAD=true

export PKGNAME="$1"
export PKGSCRIPT="$PKGDIR/$PKGNAME.sh"

source "$LIBDIR/common.sh"
source "$LIBDIR/default_build_funcs.sh"

do_fetch() { def_do_fetch; }
do_patch() { def_do_patch; }
do_build() { def_do_build; }
do_install() { def_do_install; }
do_check() { def_do_check; }

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

if [[ $STATIC = "DEF_STATIC" ]]; then
  if istrue "$IS_LIB"; then
    STATIC=0
  else
    STATIC=1
  fi
fi

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

# Remove any files from a previous install
if [[ -f "${PACKAGES_LOG}/${PKGNAME}" ]]; then
  uninstall "$PKGNAME"
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

  preinstall
  verbose "Running ${PKGNAME}.install"
  run_function do_install
  postinstall

  verbose "Running ${PKGNAME}.check"
  run_function do_check
) || exit 1

write_hash "$PKGSCRIPT"
verbose "Finished building $PKGNAME"
if istrue "$DEP_BUILD"; then
  verbose "Dependency satisfied"
fi
