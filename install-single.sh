#!/usr/bin/env bash

P=/home/eax/work/postgrespro/postgresql-install

pkill -9 postgres
make install

rm -rf $P/data
$P/bin/initdb -D $P/data

echo "max_prepared_transactions = 100" >> $P/data/postgresql.conf
echo "wal_level = hot_standby" >> $P/data/postgresql.conf
echo "wal_keep_segments = 128" >> $P/data/postgresql.conf
echo "max_connections = 10" >> $P/data/postgresql.conf
echo "listen_addresses = '*'" >> $P/data/postgresql.conf
#echo "shared_buffers = 1GB" >> $P/data/postgresql.conf
#echo "fsync = off" >> $P/data/postgresql.conf
#echo "autovacuum = off" >> $P/data/postgresql.conf

echo '' > $P/data/logfile

echo "host all all 0.0.0.0/0 trust" >> $P/data/pg_hba.conf
echo "host replication all 0.0.0.0/0 trust" >> $P/data/pg_hba.conf
echo "local replication all trust" >> $P/data/pg_hba.conf

$P/bin/pg_ctl -w -D $P/data -l $P/data/logfile start
$P/bin/createdb `whoami`
$P/bin/psql -c "create table test(k int primary key, v text);"

