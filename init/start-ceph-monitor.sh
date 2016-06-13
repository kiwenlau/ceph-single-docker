#!/bin/bash

CLUSTER=ceph
MON_NAME=$(hostname -s)
CEPH_OPTS="--cluster $CLUSTER"


if [ ! -n "$CEPH_NETWORK" ]; then
   echo "ERROR- CEPH_NETWORK must be defined as the name of the network for the OSDs"
   exit 1
fi

if [ ! -n "$MON_IP" ]; then
   echo "ERROR- MON_IP must be defined as the IP address of the monitor"
   exit 1
fi


fsid=$(uuidgen)

cat <<EOT >/etc/ceph/$CLUSTER.conf
[global]
fsid = $fsid
mon initial members = $MON_NAME
mon host = $MON_IP
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd crush chooseleaf type = 0
osd journal size = 100
osd pool default pg num = 8
osd pool default pgp num = 8
osd pool default size = 1
public network = ${CEPH_NETWORK}
cluster network = ${CEPH_NETWORK}
EOT

# Generate administrator key
ceph-authtool /etc/ceph/$CLUSTER.client.admin.keyring --create-keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'

# Generate the mon. key
ceph-authtool /etc/ceph/$CLUSTER.mon.keyring --create-keyring --gen-key -n mon. --cap mon 'allow *'

# Generate initial monitor map
monmaptool --create --add $MON_NAME $MON_IP --fsid $fsid /etc/ceph/$CLUSTER.monmap

# Import the client.admin keyring and the monitor keyring into a new, temporary one
ceph-authtool /tmp/$CLUSTER.mon.keyring --create-keyring --import-keyring /etc/ceph/$CLUSTER.client.admin.keyring

ceph-authtool /tmp/$CLUSTER.mon.keyring --import-keyring /etc/ceph/$CLUSTER.mon.keyring

# Make the monitor directory
mkdir -p /var/lib/ceph/mon/$CLUSTER-$MON_NAME

# Prepare the monitor daemon's directory with the map and keyring
ceph-mon $CEPH_OPTS --mkfs -i $MON_NAME --monmap /etc/ceph/$CLUSTER.monmap --keyring /tmp/$CLUSTER.mon.keyring

# Clean up the temporary key
rm /tmp/$CLUSTER.mon.keyring


# start MON
ceph-mon $CEPH_OPTS -i $MON_NAME -f --public-addr $MON_IP


