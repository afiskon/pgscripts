#!/bin/sh

set -e

echo "shared_preload_libraries = 'timescaledb'" >> ~/pginstall/data-master/postgresql.conf
./restart.sh
psql -c "create extension timescaledb;"
