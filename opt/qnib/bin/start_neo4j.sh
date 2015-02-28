#!/bin/bash

USAGE="Usage: $0 -p <pidfile>"
NEO4J_HOME=/usr/share/neo4j
PID_FILE=/var/run/neo4j.pid
mkdir -p $NEO4J_HOME/data/graph.db

cd $NEO4J_HOME


function watch_pid {
    while [ true ];do
        PID=$(cat ${PID_FILE})
        if [ kill ${PID} ]; then
            sleep 1
        fi
    done
}

function enable_index {
    curl -XPUT http://localhost:7474/db/data/index/auto/node/status -d true
    curl -XPOST http://localhost:7474/db/data/index/auto/node/properties -d name
}

function stop () {
  PID=$(cat ${PID_FILE})
  kill -9 ${PID}
}

trap stop SIGTERM

CLASSPATH=`find $NEO4J_HOME -name '*.jar' | xargs echo | tr ' ' ':'`

java -cp "${CLASSPATH}" \
        -Dneo4j.home="${NEO4J_HOME}" \
        -Dfile.encoding=UTF-8 \
        -Dorg.neo4j.server.properties=conf/neo4j-server.properties \
        org.neo4j.server.Bootstrapper &
echo $! > "${PID_FILE}"

watch_pid
