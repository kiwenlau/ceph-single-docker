#!/bin/bash

echo -e "\nbuild docker ceph image\n"
sudo docker build -t kiwenlau/ceph:infernalis .

echo ""