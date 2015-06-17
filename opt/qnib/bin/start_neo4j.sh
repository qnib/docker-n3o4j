#!/bin/bash

USAGE="Usage: $0 -p <pidfile>"
NEO4J_HOME=/usr/share/neo4j
PID_FILE=/usr/share/neo4j/data/neo4j-service.pid
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
  /usr/share/neo4j/bin/neo4j stop
}

trap stop SIGTERM

/usr/share/neo4j/bin/neo4j start
enable_index

watch_pid
