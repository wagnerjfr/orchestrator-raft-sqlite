FROM oraclelinux:7-slim

ENV PORT=3000
ENV RAFT=true
ENV GOPATH=/tmp/go
ENV GOFILE=go1.10.1.linux-amd64.tar.gz
ENV ORCHPATH=/usr/local

RUN yum update -y

RUN yum install -y \
  libcurl \
  rsync \
  gcc \
  gcc-c++ \
  bash \
  git \
  wget \
  which \
  perl-Digest-SHA \
  && yum clean all

RUN wget https://dl.google.com/go/$GOFILE && \
 tar -xvf $GOFILE && \
 mv go $GOPATH && \
 rm $GOFILE

ENV PATH=$GOPATH"/bin:${PATH}"

RUN mkdir -p $ORCHPATH
WORKDIR $ORCHPATH

RUN git clone https://github.com/github/orchestrator.git
WORKDIR $ORCHPATH/orchestrator

RUN ./script/build
WORKDIR $ORCHPATH/orchestrator/bin

COPY run/ $ORCHPATH/orchestrator/bin
ADD docker/entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
