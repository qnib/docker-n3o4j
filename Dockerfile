###### Docker image
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN rpm --import http://debian.neo4j.org/neotechnology.gpg.key
ADD etc/yum.repos.d/neo4j.repo /etc/yum.repos.d/neo4j.repo
RUN yum install -y neo4j lsof

VOLUME "/usr/share/neo4j/data/"

# Disable authentication and listen on 0.0.0.0/0
ADD etc/neo4j/neo4j-server.properties /etc/neo4j/neo4j-server.properties
ADD opt/qnib/bin/start_neo4j.sh /opt/qnib/bin/start_neo4j.sh
ADD etc/supervisord.d/neo4j.ini /etc/supervisord.d/neo4j.ini
ADD etc/consul.d/check_neo4j.json /etc/consul.d/
