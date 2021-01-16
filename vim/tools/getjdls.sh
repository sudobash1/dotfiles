#!/bin/sh

VER=0.9.0-201711302113
URL=http://download.eclipse.org/jdtls/milestones/$(sed 's/-.*//'<<<$VER)/jdt-language-server-${VER}.tar.gz
DEST_DIR="$(dirname "$0")/eclipse.jdt.ls"
START_SCRIPT=startjdls.sh

source "$DOTFILES_REPO/scripts/init/util.sh"

tmpdir=$(mktemp -d /tmp/getjdlsXXXXX)
trap 'rm -r "${tmpdir}"' EXIT

dest="${tmpdir}/archive.tar.xz"
download "$URL" "$dest"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"
tar xvzf "$dest"

cat <<'EOF'>$START_SCRIPT
JDT_DIR=$(dirname "$0")
PLATFORM=linux
DATA_DIR=${1:-"$(pwd)"}

java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.level=ALL \
  -noverify \
  -Dfile.encoding=UTF-8 \
  -Xmx1G \
  -jar "$JDT_DIR"/plugins/org.eclipse.equinox.launcher_*.jar \
  -configuration "$JDT_DIR/config_$PLATFORM" \
  -data "$DATA_DIR"
EOF
chmod +x $START_SCRIPT
