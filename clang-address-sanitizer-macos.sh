#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

make distclean || true

export PYTHON=/usr/bin/python
export LDFLAGS="-fsanitize=address,undefined"
export CFLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -O2 -g -O0 -I/usr/local/opt/openssl@1.1/include -L/usr/local/opt/openssl@1.1/lib"
export ASAN_OPTIONS="detect_odr_violation=0 suppressions=/Users/eax/projects/c/timescaledb/scripts/suppressions/suppr_asan.txt log_path=/tmp/sanitizer.log log_exe_name=true print_suppressions=false exitcode=27 detect_leaks=0"

./configure --prefix=$PGINSTALL \
    --with-includes=/usr/local/include --with-libraries=/usr/local/lib \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --with-perl --with-tcl --with-llvm --with-openssl
#    --with-libxml --with-libxslt --enable-nls \

# This works but generates a lot of warnings on MacOS:
# --with-gssapi --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

# Run `make install` before `make check`
# See https://www.postgresql.org/message-id/flat/CAJ7c6TN6QONSsM3%3DGPdp2DtPgFpL1cY%2BtxVwfNREWuYX9V1P%3DQ%40mail.gmail.com
make install 
# don't use -j here, 0 will be returned even in case of errors!
# make check
