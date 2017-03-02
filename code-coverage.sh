#!/bin/sh

# based on full-build.sh and http://eax.me/c-code-coverage/

set -e

make distclean || true
rm -r ~/temp/cov-report || true
mkdir ~/temp/cov-report

CFLAGS="-O0" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install \
	--enable-coverage \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-openssl --with-perl --with-tcl --with-gssapi \
    --with-libxml --with-libxslt --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check-world
# make check
make coverage
find ./ -type f -iname '*.info' | xargs genhtml -o ~/temp/cov-report/
