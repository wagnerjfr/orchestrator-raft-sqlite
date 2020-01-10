#!/bin/bash

for N in 1 2 3
do docker run -d --name orchestrator$N --net orchnet -p "300$N":3000 \
  -e PORT=3000 -e BIND=orchestrator$N \
  -e RAFT_NODES='"orchestrator1","orchestrator2","orchestrator3"' \
  orchestrator-raft:latest
done
