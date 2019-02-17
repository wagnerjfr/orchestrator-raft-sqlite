#! /bin/bash

sed -e "s/%RaftEnabled%/${RAFT}/; s/%ListenAddress%/${PORT}/; s/%RaftBind%/${BIND}/; s/%RaftNodes%/${RAFT_NODES}/" orchestrator-template-sqlite.conf.json > orchestrator.conf.json

cat orchestrator.conf.json

./orchestrator http
