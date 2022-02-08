#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true

# --with-openssl is not good for Valgrind
# see https://postgr.es/m/20170329.142112.251668726.horiguchi.kyotaro%40lab.ntt.co.jp

# to build with python2 instead of python3
export PYTHON=/usr/bin/python2

CC=/usr/bin/clang CFLAGS="-O0" ./configure --prefix=$PGINSTALL \
    --with-libxml --with-libxslt \
    --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-tcl --with-gssapi --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -j4 check
