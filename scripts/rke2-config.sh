#!/bin/bash/
export NODE_TYPE=$1
export RKE2_VERSION=$2

echo NODE_TYPE: $NODE_TYPE
echo RKE2_VERSION: $RKE2_VERSION


mkdir -p /etc/rancher/rke2

if [[ $NODE_TYPE == "init" ]]; then
  cat << EOF > /etc/rancher/rke2/config.yaml 
cloud-provider-name: aws
write-kubeconfig-mode: 644
tls-san: 
- rke-cp-elb-dSFxpW-1460165984.us-gov-west-1.elb.amazonaws.com
EOF
else 
 echo >&2 "The first positional argument must be set to 'init', 'server', or 'agent'";
 exit 1;
fi

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh -

systemctl enable rke2-server
systemctl start rke2-server