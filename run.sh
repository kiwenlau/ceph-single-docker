#!/bin/bash

LOCAL_IP=192.168.59.4
LOCAL_NETWORK=192.168.59.0/24

sudo docker rm -f ceph-monitor ceph-osd ceph-gateway > /dev/null
sudo rm -rf /etc/ceph
sudo rm -rf /var/lib/ceph

echo -e "\nstart ceph-monitor container..."

sudo docker run -itd \
                --net=host \
                -e MON_IP=$LOCAL_IP \
                -e CEPH_NETWORK=$LOCAL_NETWORK \
                -v /etc/ceph:/etc/ceph \
                -v /var/lib/ceph/:/var/lib/ceph/ \
                --name=ceph-monitor \
                kiwenlau/ceph:infernalis start-ceph-monitor.sh > /dev/null


echo -e "\nstart ceph-osd container..."

sudo docker run -itd \
                --net=host \
                --pid=host \
                --privileged=true \
                -v /etc/ceph:/etc/ceph \
                -v /var/lib/ceph/:/var/lib/ceph/ \
                --name=ceph-osd \
                kiwenlau/ceph:infernalis start-ceph-osd.sh > /dev/null

echo -e "\nstart ceph-gateway container..."

sudo docker run -itd \
                --net=host \
                -v /etc/ceph:/etc/ceph \
                -v /var/lib/ceph/:/var/lib/ceph/ \
                --name=ceph-gateway \
                kiwenlau/ceph:infernalis start-ceph-gateway.sh > /dev/null

echo ""
