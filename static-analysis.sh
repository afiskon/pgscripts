#!/bin/sh

set -e

CC=/usr/bin/clang CFLAGS="-O0 -g" \
  ./configure --enable-cassert --enable-debug
make clean
rm -r ~/temp/clang-report || true
mkdir ~/temp/clang-report
scan-build -o ~/temp/clang-report/ make -j4
