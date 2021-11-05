#!/bin/sh

grep "shared_preload_libraries = 'timescaledb'" ~/pginstall/data-master/postgresql.conf
if [ $? -ne 0 ]
then
	echo "shared_preload_libraries = 'timescaledb'" >> ~/pginstall/data-master/postgresql.conf
fi

psql -c "drop extension if exists timescaledb cascade;"
./restart.sh
psql -c "create extension timescaledb;"
