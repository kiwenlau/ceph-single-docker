#!/bin/bash

CLUSTER=ceph
CEPH_OPTS="--cluster $CLUSTER"


if [ ! -e /var/lib/ceph/osd/$CLUSTER-0/keyring ]; then
  # bootstrap OSD
  mkdir -p /var/lib/ceph/osd/$CLUSTER-0
  ceph $CEPH_OPTS osd create
  ceph-osd $CEPH_OPTS -i 0 --mkfs
  ceph $CEPH_OPTS auth get-or-create osd.0 osd 'allow *' mon 'allow profile osd' -o /var/lib/ceph/osd/$CLUSTER-0/keyring
  ceph $CEPH_OPTS osd crush add 0 1 root=default host=$(hostname -s)
  ceph-osd $CEPH_OPTS -i 0 -k /var/lib/ceph/osd/$CLUSTER-0/keyring -f 
fi
