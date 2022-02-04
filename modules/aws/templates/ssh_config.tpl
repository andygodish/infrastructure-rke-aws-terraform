Host rke-server-0
  Hostname ${server_ip_0}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop

Host rke-server-1 
  Hostname ${server_ip_1}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop

Host rke-server-2
  Hostname ${server_ip_2}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop
