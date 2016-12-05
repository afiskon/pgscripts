#!/bin/sh

set -e

CFLAGS="-O0" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-openssl --with-perl --with-tcl --with-gssapi \
    --with-libxml --with-libxslt --with-ldap --with-zstd

make clean

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check-world

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

cd src/test/recovery
make check
