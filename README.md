# Orchestrator Raft with containers

Set up a orchestrator/raft cluster for high availability.
Assuming you will run orchestrator/raft on a 3 node setup using Docker containers.

### Reference
https://github.com/github/orchestrator/blob/master/docs/raft.md

### Create a Docker network
```
$ docker network create orchnet
```

### Build Image
```
$ docker build -t orchestrator-raft:latest .
```

### Running the containers
Open 3 terminals and run each command below in one of them

#### Terminal 1
```
docker run --name orchestrator1 --net orchnet --ip 172.20.0.10 -p 3001:3000 \
  -e PORT=3000 -e BIND=172.20.0.10 \
  -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 \
  orchestrator-raft:latest
```
#### Terminal 2
```
docker run --name orchestrator2 --net orchnet --ip 172.20.0.11 -p 3002:3000 \
  -e PORT=3000 -e BIND=172.20.0.11 \
  -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 \
  orchestrator-raft:latest
```
#### Terminal 3
```
docker run --name orchestrator3 --net orchnet --ip 172.20.0.12 -p 3003:3000 \
  -e PORT=3000 -e BIND=172.20.0.12 \
  -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 \
  orchestrator-raft:latest
```
### Web API (HTTP GET access)
http://localhost:3001

http://localhost:3002

http://localhost:3003

![alt text](https://github.com/wagnerjfr/orchestrator-raft/blob/master/figure1.png)

### Stopping the containers
In another terminal run the command:
```
$ docker stop orchestrator1 orchestrator2 orchestrator3
```

### Removing the containers
```
$ docker rm orchestrator1 orchestrator2 orchestrator3
```

