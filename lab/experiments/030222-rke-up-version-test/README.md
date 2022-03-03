## Experiment (3/2/22) - Installing RKE using rke v1.3.7 

OS: Ubuntu18

In all cases, hostnamectl was used to set the hostname of each node to the fqdn as recommended by aws for use with the aws cloud controller manager. 

rke remove is being run after each test.

Tests are being performed with a minimal cluster.yml file that only includes freference to the following fields: 
- kubernetes_version
- cloud_provider (name: aws)
- network (plugin: canal)

1. rke-1.3.7 (v1.21.9-rancher1-1); result: `FATA[0290] [ "3.32.15.138" not found]`
2. rke-1.3.7 (v1.22.6-rancher1-1); result: `FATA[0290] [ "3.32.15.138" not found]`
3. rke-1.3.7 (v1.20.15-rancher1-1); result: `FATA[0290] [ "3.32.15.138" not found]`

Given sucessful history with k8s 1.20x, switching gears by attempting to explicitly define the hostname_override in the cluster.yml 

4. rke-1.3.7 (v1.20.15-rancher1-1), hostname_override: <fqdn>; result: `FATA[0290] [ "3.32.15.138" not found]`

Moving on to 1.3.6, removing the explicit hostname_override as I've had success without it in the past.

5. rke-1.3.6 (v1.20.14-rancher2-1); result: `FATA[0290] [ "3.32.15.138" not found]`
    - Ran again on a "clean" node with the same result

6. rke-1.3.5 (v1.20.14-rancher2-1); result: `FATA[0290] [ "3.32.15.138" not found]`

7. rke-1.3.4 (v1.20.14-rancher1-1); result: SUCCESS
    12. rke-1.3.4 (v1.21.8-rancher1-1); SUCESSS
    13. rke-1.3.4 (v1.22.5-rancher1-1); SUCCESS

8. rke-1.3.3 (v1.20.13-rancher1-1); result: SUCCESS
    10. rke-1.3.3 (v1.21.7-rancher1-1); SUCCESS
    11. rke-1.3.3 (v1.22.4-rancher1-1); SUCCESS

9. rke-1.3.2 (v1.20.12-rancher1-1); result: SUCCESS - 1.20 is the highest version of k8s offered by this release

The RKE up process appears to be running into issues when it reaches this point: `INFO[0097] [sync] Syncing nodes Labels and Taints`, this is after a long list of INFO logs have already been generated. 