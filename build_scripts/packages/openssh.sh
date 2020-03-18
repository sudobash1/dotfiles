DEPENDS=(
  make
  gcc
  autoconf
  automake
  pkg-config
)
LDEPENDS=(
  ldns
  libedit
  openssl
)
STATIC=false
VERSION="8.2p1"
SRC="https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${VERSION}.tar.gz"

CONFIGURE_FLAGS=(
  --without-ldns
  --with-ldns
  --with-libedit
  --with-ssl-engine
  --with-privsep-user=nobody
  --with-privsep-path="${PREFIX}/var/empty"
  --with-md5-passwords
  --with-ssl-dir="${PREFIX}"
  CFLAGS="-pthread"
  LDFLAGS="-pthread -isystem $(printf '%q' "$PREFIX/include")"
)

do_check() {
  command_exists ssh
  command_exists ssh-add
  command_exists ssh-agent
  command_exists ssh-keygen
  command_exists ssh-keyscan
  command_exists scp
  command_exists sftp
}
