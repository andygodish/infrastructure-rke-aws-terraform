# infrastructure-rke2-aws-terraform

Terraform script designed to quickly stand up nodes for an RKE cluster.

## Quick Commands

```
Rancher - Docker Quick Install

curl https://releases.rancher.com/install-docker/20.10.sh | sh

sudo usermod -aG docker $USER

reference: https://rancher.com/docs/rancher/v2.5/en/installation/requirements/installing-docker/

Set hostname for aws cloud controller manager

```
sudo hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)
```
# terraform

terraform apply -var-file=terraform.tfvars --auto-approve
terraform destroy -var-file=terraform.tfvars --auto-approve

# Install Cert Manager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.0.1/cert-manager.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```

# Install Rancher

k create ns cattle-system   

helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=rancher.andyg.io \
--set replicas=1 \
--set ingress.tls.source=secret \
--set letsEncrypy.email=agodish18@gmail.com --version=2.6.6

helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=rancher.andygodish.com \
--set ingress.tls.source=letsEncrypt \
--set letsEncrypt.email=agodish18@gmail.com \
--version=2.4.6

helm upgrade rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=upstream.andygodish.com \
--set ingress.tls.source=letsEncrypt \
--set replicas=3 \
--set letsEncrypy.email=agodish18@gmail.com --version=2.5.12

---

Query for VPC IDs - will eventually be used to identify ELBs associated with the VPC created by this tf script. 

```
aws ec2 --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Name`].Value|[0],CidrBlock:CidrBlock}' describe-vpcs
```

# PSP

Add to your cluster.yml for enabling PSPs correctly:

This only applies to RKE1, by default, in RKE2, PSP support is enabled by default, and significantly more strict when running with `profile: cis-1.5`

```
services:
  kube-api:
    pod_security_policy: true
    extra_args:
      enable-admission-plugins: "NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota"
```

Check if PSPs are enabled in the kube-apiserver with this command: 

/bin/ps -ef | grep kube-apiserver | grep -v grep | grep enable

https://docs.rke2.io/security/cis_self_assessment16/#1210


# Node template configs

### Centos7
ami-bbba86da
centos

### Server - Will likely update at some point
server-iam-profile-1JvB7h 

# rke2 configuration

export PATH=/var/lib/rancher/rke2/bin:$PATH
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
alias k=kubectl

scp rke-server-0:/tmp/rke2.yaml ~/.kube/infrastructure-rke2-aws-terrraform-config
export KUBECONFIG=~/.kube/infrastructure-rke2-aws-terrraform-config

```
echo "Waiting for rke2 config file to exist.."
while [[ ! -f /etc/rancher/rke2/rke2.yaml ]]; do
  sleep 2
done

cp /etc/rancher/rke2/rke2.yaml /tmp/rke2.yaml
sed -i -e "s/127.0.0.1/${cp_lb_host}/g" /tmp/rke2.yaml
```

sh ./rke2-config.sh agent v1.20.6+rke2r1 rke-cp-elb-GKeWbI-1912500106.us-gov-west-1.elb.amazonaws.com K10b9b1b662a10c9c9131eacadfedcc1d37d3b8c2e9f729f9edd7450f9f1d2b91c8::server:321ea10a1d4e499f7a8a5c1bbc14f500

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.22.9+rke2r1 sh -;

---


echo $(kubectl get clusterrolebinding,rolebinding -n cattle-fleet-system -o json | jq -r '.items[] | select((.subjects[].kind=="ServiceAccount" and .subjects[].name=="default") or (.subjects[].kind=="Group" and .subjects[].name=="system:serviceaccounts"))' | jq -r '"\(.roleRef.kind),\(.roleRef.name)"')

PublicIpAddress