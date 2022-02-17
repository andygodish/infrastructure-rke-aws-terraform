nodes:
    - address: ${server_ip_0}
      user: ${user}
      role:
        - controlplane
        - etcd
        - worker
      ssh_key_path: /Users/andy/.ssh/rancher-laptop
    - address: ${server_ip_1}
      user: ${user}
      role:
        - controlplane
        - etcd
        - worker
      ssh_key_path: /Users/andy/.ssh/rancher-laptop
    - address: ${server_ip_2}
      user: ${user}
      role:
        - controlplane
        - etcd
        - worker
      ssh_key_path: /Users/andy/.ssh/rancher-laptop
kubernetes_version: v1.20.12-rancher1-1
cloud_provider:
    name: aws
network: 
  plugin: canal