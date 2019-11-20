function verbose() {
  if [[ $VERBOSE != "0" ]]; then
    if [[ -n "$PKGNAME" ]]; then
      echo "$PKGNAME: $@"
    else
      echo "$@"
    fi
  fi
}
function warn() {
  if [[ -n "$PKGNAME" ]]; then
    echo "$PKGNAME: Warning: $@" >&2
  else
    echo "Warning: $@" >&2
  fi
}
function error() {
  if [[ -n "$PKGNAME" ]]; then
    echo "$PKGNAME: Error: $@" >&2
  else
    echo "Error: $@" >&2
  fi
}

function download() {
  dest="${2-$(basename "$1")}"
  verbose "Downloading '$1'"
  {
    if command -v curl >/dev/null 2>&1; then
      curl -fLo "$dest" "$1"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$dest" "$1"
    else
      echo "Download failed. No curl or wget in path"
      return 1
    fi
  } || {
    error "Unable to download '$1'"
    return 1
  }
}

function download_extract() {
  archive=$(basename "$1")

  download "$1" "$archive" || return 1

  # Get the name of the directory the tar file will extract to
  # This is a bit of a hack, but it is a reasonable assumption
  root_dir=$(tar tf "$archive" | head -n1)

  verbose "Extracting archive ($archive)"
  tar -xf "$archive" || return 1
  verbose "Entering $(pwd)/$root_dir"
  cd "$root_dir"
  [[ $? == 0 ]] || return 1
}

function command_exists() {
  if command -v "$1" >/dev/null; then
    return 0
  fi
  echo "Command $1 not found in \$PATH" >&2
  return 1
}

function istrue() {
  v=$(echo "$1" | tr "[:upper:]" "[:lower:]")
  case "$1" in
    y|yes|t|true|on|1) return 0;;
    *) return 1;;
  esac
}

function library_exists() {
    if [[ -n "$2" ]]; then
      pkg-config --atleast-version="$2" "$1" || {
        echo "Could not find $1 >= $2"
        return 1
      }
    else
      pkg-config --exists "$1" || {
        echo "Could not find $1"
        return 1
      }
    fi
}

function getprefix() {
  if istrue "$IS_LIB"; then
    prefix="$LIB_PREFIX"
  else
    prefix="$PREFIX"
  fi
  printf '%q' "$prefix"
}

function getdirpath() (
  cd "$1"
  pwd
)

function multicore_make() {
  if [[ -n $MAKE_J ]] && istrue "$MULTITHREAD"; then
    make "$MAKE_J" "$@"
  else
    make "$@"
  fi
}

if [[ -n "$NUM_CORES" ]]; then
  export MAKE_J="-j${NUM_CORES}"
else
  export MAKE_J="-j1"
fi
