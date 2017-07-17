#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true

# --with-openssl is not good for Valgrind
# see https://postgr.es/m/20170329.142112.251668726.horiguchi.kyotaro%40lab.ntt.co.jp

# tests for --with-libxml / --with-libxslt are broken on master -- 2017-07-17
# see http://afiskon.ru/s/45/7af150f1e3_regression.diffs.txt

# to build with python2 instead of python3
export PYTHON=/usr/bin/python2

CC=/usr/bin/clang CFLAGS="-O0" ./configure --prefix=$PGINSTALL \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-perl --with-tcl --with-gssapi --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check
