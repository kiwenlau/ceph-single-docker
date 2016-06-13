#!/bin/bash

CLUSTER=ceph
RGW_NAME=$(hostname -s)
RGW_CIVETWEB_PORT=80
CEPH_OPTS="--cluster $CLUSTER"


if [ ! -e /var/lib/ceph/radosgw/$RGW_NAME/keyring ]; then
  # bootstrap RGW
  mkdir -p /var/lib/ceph/radosgw/$RGW_NAME
  ceph $CEPH_OPTS auth get-or-create client.radosgw.gateway osd 'allow rwx' mon 'allow rw' -o /var/lib/ceph/radosgw/$RGW_NAME/keyring
fi

# start RGW
radosgw -d -c /etc/ceph/$CLUSTER.conf -n client.radosgw.gateway -k /var/lib/ceph/radosgw/$RGW_NAME/keyring --rgw-socket-path="" --rgw-frontends="civetweb port=$RGW_CIVETWEB_PORT"

