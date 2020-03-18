DEPENDS=(
  gcc
  libtool
  make
)
LDEPENDS=(
  openssl
)
IS_LIB=yes
VERSION=1.7.1
SRC="https://www.nlnetlabs.nl/downloads/ldns/ldns-${VERSION}.tar.gz"

CONFIGURE_FLAGS=(
  --with-drill
  --with-ssl="${PREFIX}"
)
