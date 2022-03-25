###########
# SERVERS #
###########

resource "aws_security_group" "rke_cp_sg" {
  name        = "rke-cp-sg"
  description = "Allow traffic for K8S Control Plane"
  vpc_id      = aws_vpc.rke_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "rke-cp-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_security_group_rule" "rke_cp_sg_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rke_cp_sg.id
}

resource "aws_security_group_rule" "rke_cp_ingress" {
  description       = "Ingress Control Plane"
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rke_cp_sg.id
}

###########
# SERVERS #
###########

resource "aws_instance" "server" {
  ami           = var.amis[var.region][var.os].ami
  instance_type = var.rke_server_size
  count         = 3

  root_block_device {
    volume_type = "standard"
    volume_size = 100
  }

  subnet_id                   = aws_subnet.rke_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.rke_cp_sg.id]
  associate_public_ip_address = var.is_public

  iam_instance_profile = aws_iam_instance_profile.rke_master_iam_profile.name

  key_name = "${var.tfuser}-keypair-${random_string.random_append.result}"

  user_data = base64encode(data.template_file.server_userdata.rendered)

  tags = {
    Name                                        = "rke-server-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

##########
# AGENTS #
##########

resource "aws_security_group" "rke_agent_sg" {
  name        = "rke-agent-sg-${random_string.random_append.result}"
  description = "Allow traffic for rke2 Agent"
  vpc_id      = aws_vpc.rke_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "rke-agent-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_security_group_rule" "rke_agent_sg_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rke_agent_sg.id
}


resource "aws_security_group_rule" "rke_agent_sg_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rke_agent_sg.id
}

resource "aws_security_group_rule" "rke_agent_sg_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rke_agent_sg.id
}

resource "aws_launch_template" "rke_agent_launch_template" {
  name = "rke-agent-launch-template-${random_string.random_append.result}"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.rke_agent_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.rke_agent_iam_profile.name
  }

  image_id      = var.amis[var.region][var.os].ami
  instance_type = var.rke_agent_size

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                        = "rke-agent"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "KubernetesCluster"                         = var.cluster_name
      Owner                                       = var.tfuser
    }
  }

  key_name  = "${var.tfuser}-keypair-${random_string.random_append.result}"
  user_data = base64encode(data.template_file.agent_userdata.rendered)
}

resource "aws_autoscaling_group" "rke_agent_asg" {
  name = "rke-agent-asg-${random_string.random_append.result}"

  launch_template {
    id      = aws_launch_template.rke_agent_launch_template.id
    version = "$Latest"
  }

  min_size         = var.rke_agent_count
  max_size         = var.rke_agent_count
  desired_capacity = var.rke_agent_count

  vpc_zone_identifier = [aws_subnet.rke_public_subnet_1.id, aws_subnet.rke_public_subnet_2.id]

  lifecycle {
    create_before_destroy = true
  }
}

#####################
# CONTROL PLANE ELB #
#####################

resource "aws_elb" "rke_cp_elb" {
  name = "rke-cp-elb-${random_string.random_append.result}"

  subnets = [aws_subnet.rke_public_subnet_1.id, aws_subnet.rke_public_subnet_2.id]

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name                                        = "rke-cp-elb"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }

  security_groups = [aws_security_group.rke_cp_sg.id]
}

resource "aws_elb_attachment" "rke_server0_lb_attachment" {
  elb      = aws_elb.rke_cp_elb.id
  instance = aws_instance.server[0].id
}

resource "aws_elb_attachment" "rke_initserver1_lb_attachment" {
  elb      = aws_elb.rke_cp_elb.id
  instance = aws_instance.server[1].id
}

resource "aws_elb_attachment" "rke_initserver2_lb_attachment" {
  elb      = aws_elb.rke_cp_elb.id
  instance = aws_instance.server[2].id
}
