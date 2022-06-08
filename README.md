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
--set ingress.tls.source=letsEncrypt \
--set replicas=3 \
--set letsEncrypy.email=agodish18@gmail.com --version=2.5.9

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


