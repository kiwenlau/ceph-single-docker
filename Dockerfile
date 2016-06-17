FROM ubuntu:14.04
MAINTAINER kiwenlau "kiwenlau@gmail.com"

ENV CEPH_VERSION infernalis

# install prerequisites
RUN apt-get update &&  apt-get install -y wget uuid-runtime

# install ceph
RUN wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
    echo deb http://ceph.com/debian-${CEPH_VERSION}/ trusty main | tee /etc/apt/sources.list.d/ceph-${CEPH_VERSION}.list && \
    apt-get update && \
    apt-get install -y --force-yes ceph radosgw && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY init/* /usr/local/bin/

RUN chmod +x /usr/local/bin/start-ceph-monitor.sh && \
    chmod +x /usr/local/bin/start-ceph-osd.sh && \
    chmod +x /usr/local/bin/start-ceph-gateway.sh
