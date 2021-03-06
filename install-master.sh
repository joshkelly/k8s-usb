#!/bin/bash

PWD=`pwd`

cp $PWD/bin/{etcdctl,etcd,kubectl,kube-apiserver,kube-controller-manager,kube-scheduler,kube-proxy} /usr/bin

cp $PWD/units/{etcd.service,kube-apiserver.service,kube-controller-manager.service,kube-scheduler.service,kube-proxy.service} /etc/systemd/system/

#Systemd routes not working, using hack for now
#./generate-kube-routes.sh
#cp units/kube-routes.network /etc/systemd/network
./generate-kube-routes-script.sh
cp $PWD/units/kube-routes.service /etc/systemd/system/
cp $PWD/units/kube-routes.sh /usr/local/bin
chmod +x /usr/local/bin/kube-routes.sh
systemctl enable kube-routes
systemctl start kube-routes

mkdir -p /etc/kubernetes/master
mkdir -p /etc/kubernetes/node
cp $PWD/conf/{config.conf,apiserver.conf,controller-manager.conf,scheduler.conf} /etc/kubernetes/master
cp $PWD/conf/kube-proxy.conf /etc/kubernetes/node

sed -i "/http:\/\/master/s/\/master/\/localhost/" /etc/kubernetes/node/kube-proxy.conf

./generate-kube-routes.sh
cp $PWD/units/kube-routes.network /etc/systemd/network

mkdir -p /etc/etcd
cp $PWD/conf/etcd.conf /etc/etcd

mkdir -p /srv/kubernetes/
openssl genrsa -out /srv/kubernetes/kube-serviceaccount.key

systemctl daemon-reload
systemctl enable etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy
systemctl start etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy

sleep 10

kubectl create -f kubernetes/
