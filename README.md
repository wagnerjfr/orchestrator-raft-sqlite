# Orchestrator Raft (SQLite) with containers

Set up a orchestrator/raft cluster for high availability.

You will run orchestrator/raft on a 3 node setup using Docker containers.

Each orchestrator will be using its own embedded SQLite database in this setup.

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
The orchestrators containers will be started running the command (choose one of options below):

- Option 1:
```
for N in 1 2 3
do docker run -d --name orchestrator$N --net orchnet --ip "172.20.0.1$N" -p "300$N":3000 \
  -e PORT=3000 -e BIND=orchestrator$N \
  -e NODE1=orchestrator1 -e NODE2=orchestrator2 -e NODE3=orchestrator3 \
  orchestrator-raft:latest
done
```
- Option 2:
```
for N in 1 2 3
do docker run -d --name orchestrator$N --net orchnet --ip "172.20.0.1$N" -p "300$N":3000 \
  -e PORT=3000 -e BIND="172.20.0.1$N" \
  -e NODE1=172.20.0.11 -e NODE2=172.20.0.12 -e NODE3=172.20.0.13 \
  orchestrator-raft:latest
done
```
- Option 3:
```
for N in 1 2 3
do docker run -d --name orchestrator$N --net orchnet -p "300$N":3000 \
  -e PORT=3000 -e BIND=orchestrator$N \
  -e NODE1=orchestrator1 -e NODE2=orchestrator2 -e NODE3=orchestrator3 \
  orchestrator-raft:latest
done
```

### Checking the raft status

#### Docker logs
```
$ docker logs orchestrator1
```
```
$ docker logs orchestrator2
```
```
$ docker logs orchestrator3
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

![alt text](https://github.com/wagnerjfr/orchestrator-raft-sqlite/blob/master/figures/figure1.png)

### Create a new MySQL container to be monitored by the cluster

P.S: These two project [Replication with Docker MySQL Images](https://github.com/wagnerjfr/mysql-master-slaves-replication-docker) and [Orchestrator and Replication topology using Docker containers](https://github.com/wagnerjfr/orchestrator-mysql-replication-docker) explain how to setup a MySQL master slave(s) replication topology.

Starting the container:
```
$ docker run -d --name=master --hostname=master --net orchnet --ip "172.20.0.17" \
  -v $PWD/dbMaster:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  mysql/mysql-server:5.7 \
  --server-id=1 \
  --enforce-gtid-consistency='ON' \
  --log-slave-updates='ON' \
  --gtid-mode='ON' \
  --log-bin='mysql-bin-1.log'
```
When it's ready (check first for "healthy" status running *docker ps -a*), run the command below to grant access to the orchestrator cluster:
```
$ docker exec -t master mysql -uroot -pmypass \
  -e "CREATE USER 'orc_client_user' IDENTIFIED BY 'orc_client_password';" \
  -e "GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orc_client_user';" \
  -e "GRANT SELECT ON mysql.slave_master_info TO 'orc_client_user';"
```
You can access any of the three orchestrator web interfaces to discover this new MySQL server.

Go to "Clusters -> Discover" and fill the form with the values **master** or **172.20.0.17** *(host name)* and **3306** *(port)*, to discover a new instance.

Finally go to "Clusters -> Dashboard" to visualize the topology.

![alt text](https://github.com/wagnerjfr/orchestrator-raft-sqlite/blob/master/figures/figure2.png)

### Fault tolerance scenario

Since Docker allows us to disconnect a container from a network by just running one command, we can disconnect now orchestrator1 (possibly the leader) from the groupnet network by running:
```
docker network disconnect orchnet orchestrator1
```
Check the container's logs (or the web interfaces) now. A new leader must be selected and cluster is still up and running.

### [Optional] Running one orchestrator container without raft
```
$ docker run --name orchestrator1 --net orchnet -p 3003:3000 \
  -e PORT=3000 -e RAFT=false \
  orchestrator-raft:latest
```

### Stopping the containers
In another terminal run the command:
```
$ docker stop orchestrator1 orchestrator2 orchestrator3 master
```

### Removing stopped the containers
```
$ docker rm orchestrator1 orchestrator2 orchestrator3 master
```

### Removing MySQL data directories
```
$ sudo rm -rf dbMaster
```
