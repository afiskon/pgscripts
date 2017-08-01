#!/usr/bin/env bash

# based on full-build.sh and http://eax.me/c-code-coverage/

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true
rm -r $TMPDIR/cov-report || true
mkdir $TMPDIR/cov-report

# to build with python2 instead of python3
export PYTHON=/usr/bin/python2

# tests for --with-libxml / --with-libxslt are broken on master -- 2017-07-17
# see http://afiskon.ru/s/45/7af150f1e3_regression.diffs.txt

CFLAGS="-O0" ./configure --prefix=$PGINSTALL \
	--enable-coverage \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-perl --with-tcl --with-gssapi --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check-world
# make check
make coverage
find ./ -type f -iname '*.info' | xargs genhtml -o $TMPDIR/cov-report/
