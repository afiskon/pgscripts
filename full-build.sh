#!/bin/sh

set -e

make distclean || true

CFLAGS="-O0" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-openssl --with-perl --with-tcl --with-gssapi \
    --with-libxml --with-libxslt --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check-world
