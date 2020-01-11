FROM oraclelinux:7-slim

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

ENV PORT=3000
ENV RAFT=true
ENV ORCHPATH=/usr/local/orchestrator
ENV ORCHGIT=orchestrator-git

RUN mkdir -p $ORCHPATH
WORKDIR $ORCHPATH
RUN git clone https://github.com/github/orchestrator.git $ORCHGIT

WORKDIR $ORCHPATH/$ORCHGIT
RUN ./script/build
RUN cp bin/orchestrator $ORCHPATH
RUN cd .. && rm -rf $ORCHGIT

WORKDIR $ORCHPATH/
COPY run/ $ORCHPATH/
ADD docker/entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
