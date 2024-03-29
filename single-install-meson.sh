#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

M=$PGINSTALL
U=`whoami`

pkill -9 postgres || true

rm -rf $M || true
mkdir $M

meson install -C ../postgresql/build

$M/bin/initdb --data-checksums -D $M/data-master

echo "listen_addresses = '127.0.0.1'" >> $M/data-master/postgresql.conf
echo "max_prepared_transactions = 100" >> $M/data-master/postgresql.conf
echo "wal_level = logical" >> $M/data-master/postgresql.conf
echo "max_connections = 25" >> $M/data-master/postgresql.conf
echo "wal_log_hints = on" >> $M/data-master/postgresql.conf
echo "max_wal_senders = 8" >> $M/data-master/postgresql.conf
echo "listen_addresses = '*'" >> $M/data-master/postgresql.conf
echo "hot_standby = on" >> $M/data-master/postgresql.conf
echo "max_locks_per_transaction = 256" >> $M/data-master/postgresql.conf
echo "shared_buffers = 512MB" >> $M/data-master/postgresql.conf
echo "max_wal_size = 1GB" >> $M/data-master/postgresql.conf
# echo "synchronous_commit = off" >> $M/data-master/postgresql.conf # for benchmarks
echo "max_worker_processes = 32" >> $M/data-master/postgresql.conf # for TimescaleDB
echo "timescaledb.max_background_workers = 16" >> $M/data-master/postgresql.conf # for TimescaleDB

# echo "log_statement = all" >> $M/data-master/postgresql.conf
# echo "password_encryption = scram-sha-256" >> $M/data-master/postgresql.conf
# echo "fsync = off" >> $M/data-master/postgresql.conf
# echo "autovacuum = off" >> $M/data-master/postgresql.conf

# for PGPRO EE:
# echo "shared_preload_libraries='pgpro_scheduler,pg_pathman,shared_ispell'" >> $M/data-master/postgresql.conf

echo "host replication $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf
echo "host all $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf

echo '' > $M/data-master/logfile

$M/bin/pg_ctl -w -D $M/data-master -l $M/data-master/logfile start
$M/bin/createdb $U
# $M/bin/psql -c "create table test(k int primary key, v text);"

echo 'DONE!'
