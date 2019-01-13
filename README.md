# Orchestrator Raft (SQLite) with containers

Set up a orchestrator/raft cluster for high availability.

You will run orchestrator/raft on a 3 node setup using Docker containers.

Each orchestrator will be using its own SQLite database locally in this setup.

### Reference
https://github.com/github/orchestrator/blob/master/docs/raft.md

### Clone the project and cd into the folder
```
$ git clone https://github.com/wagnerjfr/orchestrator-raft-sqlite.git

$ cd orchestrator-raft-sqlite
```

### Create a Docker network
```
$ docker network create orchnet
```

### Building the Image
Let's build the orchestrator-raft Docker image:
```
$ docker build -t orchestrator-raft:latest .
```
You should see a similar output if everything is ok:
```console
Successfully built 6d31be66c200
Successfully tagged orchestrator-raft:latest
```
It's also possible to see the new image, executing:
```
$ docker images
```

### Running the containers
The orchestrators containers will be started running the command:
```
for N in 1 2 3
do docker run -d --name orchestrator$N --net orchnet --ip "172.20.0.1$N" -p "300$N":3000 \
  -e PORT=3000 -e BIND="172.20.0.1$N" \
  -e NODE1=172.20.0.11 -e NODE2=172.20.0.12 -e NODE3=172.20.0.13 \
  orchestrator-raft:latest
done
```
### Checking the raft status

#### Docker logs
```
docker logs orchestrator1
```
```
docker logs orchestrator2
```
```
docker logs orchestrator3
```

Leader logs (sample):
```console
[martini] Started GET /api/raft-follower-health-report/be83e368/172.20.0.12/172.20.0.12 for 172.20.0.12:50424
[martini] Completed 200 OK in 1.482425ms
[martini] Started GET /api/raft-follower-health-report/be83e368/172.20.0.13/172.20.0.13 for 172.20.0.13:56276
[martini] Completed 200 OK in 1.279708ms
2018-12-15 09:28:22 DEBUG raft leader is 172.20.0.11:10008 (this host); state: Leader
2018-12-15 09:28:27 DEBUG raft leader is 172.20.0.11:10008 (this host); state: Leader
2018-12-15 09:28:27 DEBUG orchestrator/raft: applying command 69: request-health-report
```

Follower logs (sample):
```console
2018/12/16 10:40:56 [INFO] raft: Node at 172.20.0.12:10008 [Follower] entering Follower state (Leader: "")
2018-12-16 10:40:57 DEBUG Waiting for 15 seconds to pass before running failure detection/recovery
2018/12/16 10:40:57 [DEBUG] raft-net: 172.20.0.12:10008 accepted connection from: 172.20.0.11:45650
2018/12/16 10:40:58 [DEBUG] raft-net: 172.20.0.12:10008 accepted connection from: 172.20.0.11:45654
2018/12/16 10:40:58 [DEBUG] raft: Node 172.20.0.12:10008 updated peer set (2): [172.20.0.11:10008 172.20.0.12:10008 172.20.0.13:10008]
2018-12-16 10:40:58 DEBUG orchestrator/raft: applying command 2: leader-uri
2018-12-16 10:40:58 DEBUG Waiting for 15 seconds to pass before running failure detection/recovery
2018-12-16 10:40:59 DEBUG Waiting for 15 seconds to pass before running failure detection/recovery
2018-12-16 10:41:00 DEBUG Waiting for 15 seconds to pass before running failure detection/recovery
2018-12-16 10:41:01 DEBUG Waiting for 15 seconds to pass before running failure detection/recovery
2018-12-16 10:41:01 DEBUG raft leader is 172.20.0.11:10008; state: Follower
```

#### Web API (HTTP GET access)
http://localhost:3001

http://localhost:3002

http://localhost:3003

![alt text](https://github.com/wagnerjfr/orchestrator-raft-sqlite/blob/master/figure1.png)

### Running one orchestrator container without raft
```
docker run --name orchestrator1 --net orchnet -p 3003:3000 \
  -e PORT=3000 -e RAFT=false \
  orchestrator-raft:latest
```

### Stopping the containers
In another terminal run the command:
```
$ docker stop orchestrator1 orchestrator2 orchestrator3
```

### Removing stopped the containers
```
$ docker rm orchestrator1 orchestrator2 orchestrator3
```

