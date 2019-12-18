# Exit on any error
set -e

export TMPDIR="${TMPDIR:-$(pwd)/tmp}"
export PREFIX="${PREFIX:-$HOME/.sbr_local}"
export LIB_PREFIX="${LIB_PREFIX:-$PREFIX/lib_root}"
export VERBOSE="${VERBOSE:-0}"
export NUM_CORES="${NUM_CORES:-1}"
export PACKAGES_LOG="${PACKAGES_LOG:-$PREFIX/var/packages}"

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

# Find all files in PREFIX and LIB_PREFIX and write them to $PREINSTALL_FILE
function preinstall() {
  verbose "Prepairing to install ${PKGNAME}"
  preinst_files="$TMPDIR/$PKGNAME/preinst.files"
  sort <(find "$PREFIX") <(find "$LIB_PREFIX") | uniq > "$preinst_files"
}

# Find all files in PREFIX and LIB_PREFIX and compare them to $PREINSTALL_FILE
function postinstall() {
  verbose "Logging install of ${PKGNAME}"
  preinst_files="$TMPDIR/$PKGNAME/preinst.files"
  postinst_files="$TMPDIR/$PKGNAME/postinst.files"
  new_installed_files="$TMPDIR/$PKGNAME/new_installed.files"
  all_installed_files="$TMPDIR/$PKGNAME/all_installed.files"
  removed_files="$TMPDIR/$PKGNAME/postinst.rmed.files"
  sort <(find "$PREFIX") <(find "$LIB_PREFIX") | uniq > "$postinst_files"
  mkdir -p "$PACKAGES_LOG"
  comm -23 "$postinst_files" "$preinst_files" >> "$new_installed_files"
  comm -13 "$postinst_files" "$preinst_files" >> "$removed_files"
  if [[ -s "$PACKAGES_LOG/$PKGNAME" ]]; then
    sort "$PACKAGES_LOG/$PKGNAME" "$new_installed_files" \
      | uniq > "$all_installed_files"
    mv "$all_installed_files" "$PACKAGES_LOG/$PKGNAME"
  else
    cp "$new_installed_files" "$PACKAGES_LOG/$PKGNAME"
  fi
  if [[ -s $removed_files ]]; then
    warn "Files were removed:"
    cat "$removed_files" >&2
  fi
}

# Remove all installed files for packagename ($1)
function uninstall() {
  pkglog="${PACKAGES_LOG}/${1}"
  dirs=()

  if [[ ! -f "$pkglog" ]]; then
    error "$1 not installed"
    return 1
  fi

  # The realpath command is required to avoid removing files outside of the
  # prefix like this:
  #
  # /path/to/prefix/../../../file
  #
  # That should never happen, but unintended automated file removal is not
  # something we want to have happen.
  if ! command -v realpath 2>&- 1>&-; then
    error "Unable to uninstall $1. Missing the realpath command"
    return
  fi

  # Reverse-sort for the dir removal below
  sort -r "$pkglog" | while read instpath; do
    realpath=$(realpath "$instpath" 2>&-)
    if [[ -z $realpath ]]; then
      warn "No such path \`$instpath'"
      continue
    fi

    # Save dirs for later after the files have been removed
    if [[ -d "$realpath" ]]; then
      dirs+=("$realpath")
      continue
    fi

    # Make sure the file is within a prefix.
    case ${realpath} in
      $(realpath "$PREFIX")/*) ;;
      $(realpath "$LIB_PREFIX")/*) ;;
      *) warn "Path not in prefix: \`$instpath'"; continue ;;
    esac

    if [[ -f "$realpath" ]]; then
      verbose "Removing \`${realpath}'"
    else
      verbose "File missing: \`${realpath}'"
    fi

    rm -f "${realpath}"
  done

  # Scan for now empty directories. Assume that directories with files
  # remaining in them are shared by other packages. This may result in orphaned
  # directories, but better be safe than sorry.
  #
  # Any empty dirs containing other empty dirs should have the subdirs removed
  # first because the pkg install files were reversed sorted
  for dir in "${dirs[@]}"; do
    if [[ "$(find "$dir" -mindepth 1 2>&-)" ]]; then
      warn "Skipping non-empty directory \`$dir'"
    else
      verbose "Removing empty directory \`$dir'"
      rmdir "$dir"
    fi
  done
  rm -f "$pkglog"
  verbose "Finished uninstalling $1"
}

make_dirs

source "$LIBDIR/tools.sh"
