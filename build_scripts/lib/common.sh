# Exit on any error
set -e

export TMPDIR=${TMPDIR:-$(pwd)/tmp}
export PREFIX=${PREFIX:-$HOME/.sbr_local}
export LIB_PREFIX=${LIB_PREFIX:-$PREFIX/lib_root}
export VERBOSE=${VERBOSE:-0}
export NUM_CORES=${NUM_CORES:-1}

# Variables which affect the build and should be included in the hash
# Users should also confirm them
env_vars=(
  TMPDIR PREFIX LIB_PREFIX
)
# Variables which do not affect the build, but should still be
# confirmed by the user
extra_vars=(
  NUM_CORES VERBOSE
)

# Get the hash of a passed in func/script ($1)
function get_hash() {
  # Use md5sum or shasum if it exists, else use the content
  if command -v shasum 2>/dev/null; then
    hasher=sha1sum
  elif command -v md5sum 2>/dev/null; then
    hasher=md5sum
  else
    hasher=cat # No hasher, just use content
  fi
  if [[ $(type -t "$1") = "function" ]]; then
    declare -pf $1 | $hasher
  else
    $hasher "$1"
    for p in "$PKGDIR"/patches/"$PKGNAME"_*.patch; do
      [[ ! -f "$p" ]] && continue
      $hasher "$p"
    done
  fi
  for var in "${env_vars[@]}"; do
    echo "$var=${!var}"
  done
}

# Check the hash of a script ($1) to see if it needs to be rerun
function check_hash() {
  f="$TMPDIR/.$(basename "$1").hash"
  [[ -f "$f" ]] || return 1 # No hash
  hash_old="$(< "$f")"
  hash_new="$(get_hash "$1")"
  [[ "$hash_old" = "$hash_new" ]] || return 1
  return 0
}

# Write the hash of a just-run script ($1)
function write_hash() {
  f="$TMPDIR/.$(basename "$1").hash"
  rm -rf "$f"
  get_hash "$1" > "$f"
}

# Remove the hash of a script ($1)
function remove_hash() {
  f="$TMPDIR/.$(basename "$1").hash"
  rm -rf "$f"
}

# Run a func/script ($1) with args ($2...) using set -e to exit on first error
function try() {
  func="$1"
  shift 1
  LASTDIR_FILE=$(mktemp) || {
    error "Could not create temp file"
    return 1
  }
  (
    export LF=$LASTDIR_FILE
    if [[ $(type -t "$func") = "function" ]]; then
      export -f "$func"
    fi
    export -f assemble_array
    exec bash -c "
      set -e;
      source '$LIBDIR/tools.sh';
      source '$LIBDIR/default_build_funcs.sh';
      [[ -f '$PKGDIR/${PKGNAME}.sh' ]] && source '$PKGDIR/${PKGNAME}.sh'
      $func "'"$@"'";
      pwd>'$LF'
    " bash "$@"
  ) || {
    rm -f "$LASTDIR_FILE"
    return 1
  }
  cd "$(cat "$LASTDIR_FILE")" || true
  rm -f "$LASTDIR_FILE"
}

# Run func ($1) and exit if it fails
function run_function() {
  if ! try "$1"; then
    error "Error in $1 step of $PKGNAME"
    exit 1
  fi
}

function verify_settings {
  column="$(command -v column 2>/dev/null && echo " -t" || echo "cat")"
  if [[ -z "$NO_VERIFY_SETTINGS" ]]; then
    for setting in "${env_vars[@]}" "${extra_vars[@]}"; do
      echo "${setting} = ${!setting}"
    done | $column

    ans=""
    while [[ $ans != "y" && $ans != "n" ]]; do
      read -N 1 -p "Are these settings correct [y/n]? " ans
      echo
      ans="$(tr '[:upper:]' '[:lower:]' <<< $ans)"
    done
    [[ $ans != "y" ]] && exit 1
    export NO_VERIFY_SETTINGS=1
  fi
  # TODO: validate the settings
  # TODO: Make sure paths are absolute
}

function make_dirs() {
  orig_dir="$(pwd)"
  mkdir -p "$TMPDIR" || { echo "Connot create dir: '$TMPDIR'"; exit 1;}
  cd "$TMPDIR" || { echo "Connot enter dir: '$TMPDIR'"; exit 1;}
  TMPDIR="$(pwd)"
  cd "$orig_dir"
  mkdir -p "$PREFIX" || { echo "Connot create dir: '$PREFIX'"; exit 1;}
  cd "$PREFIX" || { echo "Connot enter dir: '$PREFIX'"; exit 1;}
  mkdir -p usr lib share bin
  PREFIX="$(pwd)"
  cd "$orig_dir"
}

# Export an array ($1) into multiple variables
function export_array() {
  name="$1"
  #shellcheck disable=2016
  eval 'array=("${'"$name"'[@]}")'
  len=${#array[@]}
  declare -gx "${name}_len=$len"
  for ((i=0; i<len; i++)); do
    declare -gx "${name}_${i}=${array[$i]}"
  done
}

# Reassemble an array from export_array into var named $1
function assemble_array() {
  name="$1"
  array=()
  len_var="${name}_len"
  len=${!len_var}
  for ((i=0; i<len; i++)); do
    var="${name}_${i}"
    array+=("${!var}")
  done
  #shellcheck disable=2016
  declare -ag "$name=("'"${array[@]}")'
}

verify_settings
make_dirs

source "$LIBDIR/tools.sh"
