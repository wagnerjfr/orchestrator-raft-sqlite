FROM oraclelinux:7-slim

ENV PORT=3000

COPY bin/ /usr/local/orchestrator

WORKDIR /usr/local/orchestrator

ADD docker/entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
