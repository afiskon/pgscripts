#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

M=$PGINSTALL
U=`whoami`

rm -r /tmp/valgrind || true
mkdir /tmp/valgrind

pkill -9 postgres || true

rm -rf $M || true
mkdir $M

sed -i 's|/\* #define USE_VALGRIND \*/|#define USE_VALGRIND|g' src/include/pg_config_manual.h

ninja -C ../postgresql/build clean
ninja -C ../postgresql/build

meson install -C ../postgresql/build

$M/bin/initdb --data-checksums -D $M/data

echo "listen_addresses = '127.0.0.1'" >> $M/data/postgresql.conf
echo "max_prepared_transactions = 100" >> $M/data/postgresql.conf
echo "wal_level = logical" >> $M/data/postgresql.conf
echo "max_connections = 25" >> $M/data/postgresql.conf
echo "wal_log_hints = on" >> $M/data/postgresql.conf
echo "max_wal_senders = 8" >> $M/data/postgresql.conf
echo "listen_addresses = '*'" >> $M/data/postgresql.conf
echo "hot_standby = on" >> $M/data/postgresql.conf
echo "max_locks_per_transaction = 256" >> $M/data/postgresql.conf
echo "shared_buffers = 512MB" >> $M/data/postgresql.conf

echo '!!!'
echo '!!! After PostgreSQL will start run:'
echo '!!!'
echo '!!!     meson test -C build --setup running --suite regress-running --timeout-multiplier 0'
echo "!!!     $M/bin/pg_ctl -w -D $PGINSTALL/data stop"
echo "!!!     grep -r 'ERROR SUMMARY' /tmp/valgrind/ | grep -v 'SUMMARY: 0 errors'"
echo '!!!'
echo '!!! ... in the second terminal.'
echo '!!!'

#  --vgdb=yes --vgdb-error=1 \

valgrind \
  --leak-check=full \
  --show-leak-kinds=definite,indirect \
  --track-origins=yes \
  --gen-suppressions=all \
  --read-var-info=yes \
  --log-file=/tmp/valgrind/%p.log \
  --suppressions=src/tools/valgrind.supp \
  --time-stamp=yes \
  --trace-children=yes \
  $M/bin/postgres -D $PGINSTALL/data \
  2>&1 | tee /tmp/valgrind/postmaster.log
