nodes:
    - address: ${server_ip}
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