data "template_file" "server_userdata" {
  template = file("${path.module}/templates/server_userdata.sh")
}

data "template_file" "agent_userdata" {
  template = file("${path.module}/templates/agent_userdata.sh")
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl",
    {
      server_ip_0 = aws_instance.server[0].public_ip
      server_ip_1 = aws_instance.server[1].public_ip
      server_ip_2 = aws_instance.server[2].public_ip
      user = var.amis[var.region][var.os].user
    }
  )
  filename = "ssh_config"
}

resource "local_file" "cluster_yml" {
  content = templatefile("${path.module}/templates/cluster_yml.tpl",
    {
      server_ip_0 = aws_instance.server[0].public_ip
      server_ip_1 = aws_instance.server[1].public_ip
      server_ip_2 = aws_instance.server[2].public_ip
      user = var.amis[var.region][var.os].user
    }
  )
  filename = "cluster.yml"
}

resource "local_file" "instance_profile" {
  content = templatefile("${path.module}/templates/instance_profile.tpl",
    {
      server_iam_profile = aws_iam_instance_profile.rke_master_iam_profile.name
      agent_iam_profile = aws_iam_instance_profile.rke_agent_iam_profile.name
    }
  )
  filename = "instance_profile.yml"
}