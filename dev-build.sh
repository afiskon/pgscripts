#!/bin/sh

CFLAGS="-O0" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install --enable-tap-tests --enable-cassert --enable-debug && \
  make clean && \
  echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-' && \
  make -s -j4 && \
  echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-' && \
  make check-world
