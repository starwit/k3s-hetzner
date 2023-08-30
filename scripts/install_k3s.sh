#!/bin/bash

IP=${1} 

echo "starting to install k3s, using ${IP} as bind address"

curl -sfL https://get.k3s.io | sh -s - --cluster-cidr 192.168.176.0/20 --node-external-ip=${IP} --node-ip=${IP} --advertise-address=${IP} --flannel-iface=tailscale0

echo "k3s installation done"