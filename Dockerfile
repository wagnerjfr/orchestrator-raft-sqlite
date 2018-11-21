  FROM oraclelinux:7-slim

  EXPOSE 3000

  COPY bin/ /usr/local/orchestrator
  COPY bin/orchestrator.conf.json /usr/local/orchestrator/etc/orchestrator.conf.json

  WORKDIR /usr/local/orchestrator
  ADD docker/entrypoint.sh /entrypoint.sh
  CMD /entrypoint.sh
