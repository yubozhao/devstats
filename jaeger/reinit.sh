#!/bin/bash
function finish {
    sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
fi
./grafana/influxdb_recreate.sh jaeger_temp || exit 1
GHA2DB_CMDDEBUG=1 GHA2DB_RESETIDB=1 GHA2DB_LOCAL=1 GHA2DB_PROJECT=jaeger PG_DB=jaeger IDB_DB=jaeger_temp ./gha2db_sync || exit 2
GHA2DB_LOCAL=1 GHA2DB_PROJECT=jaeger IDB_DB=jaeger_temp ./idb_vars || exit 3
./grafana/influxdb_recreate.sh jaeger || exit 4
IDB_DB_SRC=jaeger_temp IDB_DB_DST=jaeger ./idb_backup || exit 5
./grafana/influxdb_drop.sh jaeger_temp
