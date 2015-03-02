#!/bin/bash

USAGE="Usage: $0 -p <pidfile>"
NEO4J_HOME=/usr/share/neo4j
PID_FILE=/var/run/neo4j.pid
mkdir -p $NEO4J_HOME/data/graph.db

cd $NEO4J_HOME


function watch_pid {
    sleep 2
    while [ true ];do
        PID=$(cat ${PID_FILE})
        if [ -d "/proc/${PID}" ]; then
            sleep 1
	else 
            return 0
        fi
    done
}

function wait_running {
    curl -s -XGET http://localhost:7474/db/data/ 1>/dev/null 2>&1
    if [ $? -ne 0 ];then
        sleep 1
        wait_running
    fi
}

function enable_index {
    curl -XPUT http://localhost:7474/db/data/index/auto/node/status -d true
    curl -XPOST http://localhost:7474/db/data/index/auto/node/properties -d name
    curl -XPOST http://localhost:7474/db/data/index/node/ -d """{
        "name" : "node_auto_index",
        "config" : {
            "type" : "fulltext",
            "provider" : "lucene"
        }
    }"""
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

wait_running
enable_index

watch_pid
