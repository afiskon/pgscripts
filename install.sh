#!/usr/bin/env bash

set -e

M=/home/eax/work/postgrespro/postgresql-install
U=`whoami`

pkill -9 postgres || true

rm -rf $M || true
mkdir $M

make install

$M/bin/initdb -D $M/data-master

echo "listen_addresses = '127.0.0.1'" >> $M/data-master/postgresql.conf
echo "max_prepared_transactions = 100" >> $M/data-master/postgresql.conf
echo "wal_level = hot_standby" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 128" >> $M/data-master/postgresql.conf
echo "max_connections = 10" >> $M/data-master/postgresql.conf
echo "wal_log_hints = on" >> $M/data-master/postgresql.conf
echo "max_wal_senders = 8" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 64" >> $M/data-master/postgresql.conf
echo "listen_addresses = '*'" >> $M/data-master/postgresql.conf
echo "hot_standby = on" >> $M/data-master/postgresql.conf
echo "log_statement = all" >> $M/data-master/postgresql.conf
echo "max_locks_per_transaction = 256" >> $M/data-master/postgresql.conf
#echo "shared_buffers = 1GB" >> $M/data-master/postgresql.conf
#echo "fsync = off" >> $M/data-master/postgresql.conf
#echo "autovacuum = off" >> $M/data-master/postgresql.conf

echo "host replication $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf

echo "host all $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf

echo '' > $M/data-master/logfile

echo "=== STARTING MASTER ==="

$M/bin/pg_ctl -w -D $M/data-master -l $M/data-master/logfile start
$M/bin/createdb $U
$M/bin/psql -c "create table test(k int primary key, v text);"

echo "=== RUNNING PG_BASEBACKUP ==="

$M/bin/pg_basebackup -P -R -X stream -c fast -h 127.0.0.1 -U $U -D $M/data-slave
echo "port = 5433" >> $M/data-slave/postgresql.conf

echo "=== STARTING SLAVE ==="

$M/bin/pg_ctl -w -D $M/data-slave -l $M/data-slave/logfile start
