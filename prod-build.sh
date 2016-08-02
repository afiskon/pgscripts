#!/bin/sh

CFLAGS="-O2" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install --enable-debug --enable-tap-tests && \
  make clean && \
  echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-' && \
  make -s -j4 && \
  echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-' && \
  make check
