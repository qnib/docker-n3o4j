#!/bin/sh

USAGE="Usage: $0 -p <pidfile>"
NEO4J_HOME=/usr/share/neo4j

mkdir -p $NEO4J_HOME/data/graph.db

cd $NEO4J_HOME

CLASSPATH=`find $NEO4J_HOME -name '*.jar' | xargs echo | tr ' ' ':'`

java -cp "${CLASSPATH}" \
        -Dneo4j.home="${NEO4J_HOME}" \
        -Dfile.encoding=UTF-8 \
        -Dorg.neo4j.server.properties=conf/neo4j-server.properties \
        org.neo4j.server.Bootstrapper 

