# Orchestrator Raft with containers
## Binary already compiled

### Create a Docker network
```
$ docker network create orchnet
```

### Build Image
```
$ docker build -t orchestrator:latest .
```

### Run Container
Open 3 terminals and run each line below in one of them

#### Terminal 1
```
$ docker run --rm --name orchestrator1 --net orchnet --ip 172.20.0.10 -p 3001:3000 -e PORT=3000 -e BIND=172.20.0.10 -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 orchestrator:latest
```
#### Terminal 2
```
$ docker run --rm --name orchestrator2 --net orchnet --ip 172.20.0.11 -p 3002:3000 -e PORT=3000 -e BIND=172.20.0.11 -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 orchestrator:latest
```
#### Terminal 3
```
$ docker run --rm --name orchestrator3 --net orchnet --ip 172.20.0.12 -p 3003:3000 -e PORT=3000 -e BIND=172.20.0.12 -e NODE1=172.20.0.10 -e NODE2=172.20.0.11 -e NODE3=172.20.0.12 orchestrator:latest
```
