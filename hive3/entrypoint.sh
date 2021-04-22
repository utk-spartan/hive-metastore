#!/usr/bin/env bash

set -xeuo pipefail
test -v HIVE_METASTORE_JDBC_URL
test -v HIVE_METASTORE_USER
test -v HIVE_METASTORE_PASSWORD
export HIVE_METASTORE_DB_HOST="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 3 | cut -d : -f 1)"
export HIVE_METASTORE_DB_NAME="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 4)"
sed -i \
  -e "s|%S3_ENDPOINT%|${S3_ENDPOINT:-}|g" \
  -e "s|%S3_ACCESS_KEY%|${S3_ACCESS_KEY:-}|g" \
  -e "s|%S3_SECRET_KEY%|${S3_SECRET_KEY:-}|g" \
  /opt/hive-metastore/conf/metastore-site.xml

if [[ "$HIVE_METASTORE_DRIVER" == com.mysql.jdbc.Driver ]]; then
    sqlDir=/opt/hive-metastore/scripts/metastore/upgrade/mysql
    function sql() {
        mysql --host="$HIVE_METASTORE_DB_HOST" --user="$HIVE_METASTORE_USER" --password="$HIVE_METASTORE_PASSWORD" "$HIVE_METASTORE_DB_NAME" "$@"
    }
    # Make sure that mysql is accessible
    sql -e 'SELECT 1'
    
    # sql < "${sqlDir}/hive-schema-1.2.0.mysql.sql"
    # sql < "${sqlDir}/upgrade-1.2.0-to-2.0.0.mysql.sql"
    # sql < "${sqlDir}/upgrade-2.0.0-to-2.1.0.mysql.sql"
    # sql < "${sqlDir}/upgrade-2.1.0-to-2.2.0.mysql.sql"
    # sql < "${sqlDir}/upgrade-2.2.0-to-2.3.0.mysql.sql"
    # sql < "${sqlDir}/upgrade-2.3.0-to-3.0.0.mysql.sql"
# upgrade-2.0.0-to-2.1.0.mysql.sql
# HIVE-13354 : Add ability to specify Compaction options per table and …
# 5 years ago
# upgrade-2.1.0-to-2.2.0.mysql.sql
# HIVE-12274 Increase width of columns used for general configuration i…
# 4 years ago
# upgrade-2.2.0-to-2.3.0.mysql.sql

    # if ! sql -e 'SELECT 1 FROM DBS LIMIT 1'; then
    #     find ${sqlDir} -type f | sort -n | while read sqlFile; do
    #         cat "$sqlFile" | sql
    #     done
    # fi
elif [[ "$HIVE_METASTORE_DRIVER" == org.postgresql.Driver ]]; then
    function sql() {
        export PGPASSWORD="$HIVE_METASTORE_PASSWORD"
        psql --host="$HIVE_METASTORE_DB_HOST" --username="$HIVE_METASTORE_USER" "$HIVE_METASTORE_DB_NAME" "$@"
    }
    # Make sure that postgres is accessible
    sql -c 'SELECT 1'
    if ! sql -c 'SELECT 1 FROM "DBS" LIMIT 1'; then
        find /opt/sql/postgres -type f | sort -n | while read sqlFile; do
            sql -f "$sqlFile"
        done
    fi
else
    echo "Unsupported driver: $$HIVE_METASTORE_DRIVER" >&2
    exit 1
fi
# log threshold is set to INFO to avoid log pollution from Datanucleus
exec /opt/hive-metastore/bin/start-metastore --hiveconf hive.root.logger=INFO,console --hiveconf hive.log.threshold=INFO --hiveconf javax.jdo.option.ConnectionURL=$HIVE_METASTORE_JDBC_URL --hiveconf javax.jdo.option.ConnectionUserName=$HIVE_METASTORE_USER --hiveconf javax.jdo.option.ConnectionPassword=$HIVE_METASTORE_PASSWORD