#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

rm -r $TMPDIR/postgresql-valgrind || true
mkdir $TMPDIR/postgresql-valgrind

M=$PGINSTALL
U=`whoami`

pkill -9 postgres || true

rm -rf $M || true
mkdir $M

make install

$M/bin/initdb -D $M/data-master

echo "max_prepared_transactions = 100" >> $M/data-master/postgresql.conf
echo "wal_level = logical" >> $M/data-master/postgresql.conf
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

echo '!!!'
echo '!!! Hint: after PostgreSQL will start run `make installcheck` or '
echo '!!! `make installcheck-tests TESTS="password jsonb"` in the second terminal'
echo '!!!'
echo '!!! And make sure USE_VALGRIND is defined in src/include/pg_config_manual.h'
echo '!!!'

#  --vgdb=yes --vgdb-error=1 \

# No point to check for memory leaks, Valgrind doesn't understand MemoryContexts and stuff
valgrind --leak-check=no --track-origins=yes --gen-suppressions=all \
  --read-var-info=yes \
  --log-file=$TMPDIR/postgresql-valgrind/%p.log \
  --suppressions=src/tools/valgrind.supp --time-stamp=yes \
  --trace-children=yes postgres -D \
  $PGINSTALL/data-master \
  2>&1 | tee $TMPDIR/postgresql-valgrind/postmaster.log

