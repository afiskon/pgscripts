#!/usr/bin/env bash

set -e

CC=/usr/bin/clang CFLAGS="-O0 -g" \
  ./configure --enable-cassert --enable-debug
make clean
rm -r $TMPDIR/clang-report || true
mkdir $TMPDIR/clang-report
scan-build -o $TMPDIR/clang-report/ make -j4
