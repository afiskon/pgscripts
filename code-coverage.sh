#!/usr/bin/env bash

# based on full-build.sh and http://eax.me/c-code-coverage/
# see also https://www.postgresql.org/docs/current/regress-coverage.html
# note that the script works only with GCC stack

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true
make coverage-clean || true

CFLAGS="-O0" ../postgresql/configure --prefix=$PGINSTALL \
    --enable-coverage \
    --enable-tap-tests --enable-cassert --enable-debug \
    --with-openssl --with-libxml --with-libxslt
#   --with-tcl --with-python --with-perl --enable-nls \

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4 world

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check-world
make coverage-html

echo "DONE! See coverage/index.html"
