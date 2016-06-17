##Run Ceph within Docker Containers

####pull ceph image

```
sudo docker pull kiwenlau/ceph:infernalis
```

####run containers

```
git clone https://github.com/kiwenlau/ceph-single-docker
cd ceph-single-docker/
sudo ./run.sh
```

####create ceph user

```
sudo docker exec ceph-monitor radosgw-admin user create --uid="kiwenlau" --display-name="kiwenlau" --email=kiwenlau@gmail.com
```

