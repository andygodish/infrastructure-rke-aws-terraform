#!/bin/bash

rm ./lab/rke-0/*
rm ./lab/rke-1/*
rm ./lab/rke-2/*

# Needs to match: *****
rm ./lab/playbooks/inventory/hosts.ini
rm ./lab/playbooks/inventory/group_vars/all.yml

terraform apply -var-file=terraform.tfvars --auto-approve

mv rke-0.yml ./lab/rke-0/cluster.yml 
mv rke-1.yml ./lab/rke-1/cluster.yml
mv rke-2.yml ./lab/rke-2/cluster.yml

#                 *****
mv hosts.ini ./lab/playbooks/inventory/hosts.ini
mv all.yml ./lab/playbooks/inventory/group_vars/all.yml