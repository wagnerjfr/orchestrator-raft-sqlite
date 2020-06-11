FROM oraclelinux:7-slim as build

RUN yum update -y && yum clean all

RUN yum install -y \
  libcurl \
  rsync \
  gcc \
  gcc-c++ \
  bash \
  git \
  which \
  perl-Digest-SHA \
  oracle-golang-release-el7 \
  && yum clean all

RUN yum install -y \
  golang \
  && yum clean all

ENV ORCHPATH=/usr/local/orchestrator
ENV ORCHGIT=orchestrator-git

RUN mkdir -p $ORCHPATH
WORKDIR $ORCHPATH
RUN git clone https://github.com/github/orchestrator.git $ORCHGIT

WORKDIR $ORCHPATH/$ORCHGIT
RUN ./script/build
RUN cp -rf bin/orchestrator bin/resources $ORCHPATH
RUN cd .. && rm -rf $ORCHGIT

FROM oraclelinux:7-slim

ENV PORT=3000
ENV RAFT=true

ENV ORCHPATH=/usr/local/orchestrator

COPY --from=build /usr/local/orchestrator $ORCHPATH

WORKDIR $ORCHPATH/
COPY run/ .
ADD docker/entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
