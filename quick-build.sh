#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true

export PYTHON=/usr/bin/python

unamestr=$(uname)
if [[ "$unamestr" == 'FreeBSD' ]]; then
	export CFLAGS="-O0 -I/usr/local/include"
	export LDFLAGS="-L/usr/local/lib"
else
	export CFLAGS="-O0"
fi

../postgresql/configure --prefix=$PGINSTALL \
    --enable-tap-tests --enable-cassert --enable-debug \
    --with-openssl
#   --with-tcl --with-python --with-perl --with-libxml --with-libxslt --enable-nls \

# This works but generates a lot of warnings on MacOS:
# --with-gssapi --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

# Run `make install` before `make check`
# See https://www.postgresql.org/message-id/flat/CAJ7c6TN6QONSsM3%3DGPdp2DtPgFpL1cY%2BtxVwfNREWuYX9V1P%3DQ%40mail.gmail.com
make install 
# don't use -j here, 0 will be returned even in case of errors!
make check

echo 'DONE!'
