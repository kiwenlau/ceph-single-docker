FROM ubuntu:14.04
MAINTAINER kiwenlau "kiwenlau@gmail.com"

ENV ETCDCTL_VERSION v2.2.4
ENV ETCDCTL_ARCH linux-amd64
ENV KVIATOR_VERSION 0.0.5
ENV CONFD_VERSION 0.10.0

ENV CEPH_VERSION infernalis

# install prerequisites
RUN apt-get update &&  apt-get install -y wget unzip uuid-runtime

# install ceph
RUN wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
    echo deb http://ceph.com/debian-${CEPH_VERSION}/ trusty main | tee /etc/apt/sources.list.d/ceph-${CEPH_VERSION}.list && \
    apt-get update && apt-get install -y --force-yes ceph radosgw && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# install etcdctl
RUN wget -q -O- "https://github.com/coreos/etcd/releases/download/${ETCDCTL_VERSION}/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}.tar.gz" |tar xfz - -C/tmp/ etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl && \
    mv /tmp/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl /usr/local/bin/etcdctl

# install kviator
RUN wget https://github.com/AcalephStorage/kviator/releases/download/v${KVIATOR_VERSION}/kviator-${KVIATOR_VERSION}-linux-amd64.zip && \
    cd /usr/local/bin && \
    unzip /kviator-${KVIATOR_VERSION}-linux-amd64.zip && \
    chmod +x /usr/local/bin/kviator && \
    rm /kviator-${KVIATOR_VERSION}-linux-amd64.zip

# install confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    mv /confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd && \
    chmod +x /usr/local/bin/confd && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

COPY init/* /usr/local/bin/

RUN chmod +x /usr/local/bin/start-ceph-monitor.sh && \
    chmod +x /usr/local/bin/start-ceph-osd.sh && \
    chmod +x /usr/local/bin/start-ceph-gateway.sh
