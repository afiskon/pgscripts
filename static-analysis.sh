#!/usr/bin/env bash

set -e

CHECKER=/Users/eax/opt/checker-279

make distclean || true
CC=/usr/bin/clang CFLAGS="-O0 -g" \
  ./configure --enable-cassert --enable-debug
make clean
rm -r $TMPDIR/clang-report || true
mkdir $TMPDIR/clang-report
$CHECKER/bin/scan-build -o $TMPDIR/clang-report/ make -j4
