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

# Install Rancher

k create ns cattle-system   

helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=upstream.andygodish.com \
--set ingress.tls.source=letsEncrypt \
--set replicas=3 \
--set letsEncrypy.email=agodish18@gmail.com --version=2.5.12

helm upgrade rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=upstream.andygodish.com \
--set ingress.tls.source=letsEncrypt \
--set replicas=3 \
--set letsEncrypy.email=agodish18@gmail.com --version=2.5.12