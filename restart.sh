#!/usr/bin/env bash

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

M=$PGINSTALL
$M/bin/pg_ctl -w -D $M/data-master -l $M/data-master/logfile restart

