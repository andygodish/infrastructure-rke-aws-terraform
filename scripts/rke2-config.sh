#!/bin/bash/
NODE_TYPE=$1
RKE2_VERSION=$2
CP_LB=$3
TOKEN=$4

echo NODE_TYPE: $NODE_TYPE
echo RKE2_VERSION: $RKE2_VERSION
echo CP_LB: $CP_LB
echo TOKEN: $TOKEN

mkdir -p /etc/rancher/rke2

if [[ $NODE_TYPE == "init" ]]; then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3;
  chmod 700 get_helm.sh;
  ./get_helm.sh;
  mv /usr/local/bin/helm /bin/helm;
  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable;

  cat << EOF > /etc/rancher/rke2/config.yaml 
cloud-provider-name: aws
write-kubeconfig-mode: 644
tls-san: 
- $CP_LB
EOF
elif [[ $NODE_TYPE == "agent" ]]; then
  cat << EOF > /etc/rancher/rke2/config.yaml 
token: $TOKEN
server: https://$CP_LB:9345
EOF
else 
 echo >&2 "The first positional argument must be set to 'init', 'server', or 'agent'";
 exit 1;
fi

if [[ $NODE_TYPE == "init" ]]; then
  curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh -;
elif [[ $NODE_TYPE == "agent" ]]; then
  curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION INSTALL_RKE2_TYPE="agent" sh -;
fi  

if [[ $NODE_TYPE == "init" ]]; then
  systemctl enable rke2-server;
  systemctl start rke2-server;
elif [[ $NODE_TYPE == "agent" ]]; then
  systemctl enable rke2-agent;
  systemctl start rke2-agent; 
fi