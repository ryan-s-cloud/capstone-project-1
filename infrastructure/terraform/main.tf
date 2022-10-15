variable "region" {
  default = "us-east-2"
}

resource "aws_vpc" "k8s" {
  cidr_block           = "10.240.0.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "kubernetes-simplilearn"
  }
}

resource "aws_vpc_dhcp_options" "k8s" {
  domain_name         = "us-east-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_vpc_dhcp_options_association" "k8s" {
  vpc_id          = "${aws_vpc.k8s.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s.id}"
}

resource "aws_subnet" "k8s" {
  vpc_id     = "${aws_vpc.k8s.id}"
  cidr_block = "10.240.0.0/24"

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_route_table" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s.id}"
  }

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_route_table_association" "k8s" {
  subnet_id      = "${aws_subnet.k8s.id}"
  route_table_id = "${aws_route_table.k8s.id}"
}

resource "aws_security_group" "k8s" {
  name        = "kubernetes"
  description = "Kubernetes security group"
  vpc_id      = "${aws_vpc.k8s.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.240.0.0/24", "10.200.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # May be wrong
  ingress {
    from_port   = 0
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # define the outbound rule, allow all kinds of accesses from anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_lb" "k8s" {
  name               = "kubernetes"
  subnets            = ["${aws_subnet.k8s.id}"]
  internal           = false
  load_balancer_type = "network"
}

resource "aws_lb_target_group" "k8s" {
  name        = "kubernetes"
  protocol    = "TCP"
  port        = 6443
  vpc_id      = "${aws_vpc.k8s.id}"
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "k8s" {
  count            = "${length(var.controller_ips)}"
  target_group_arn = "${aws_lb_target_group.k8s.arn}"
  target_id        = "${var.controller_ips[count.index]}"
}

resource "aws_lb_listener" "k8s" {
  load_balancer_arn = "${aws_lb.k8s.arn}"
  protocol          = "TCP"
  port              = 6443

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.k8s.arn}"
  }
}

# Sends your public key to the instance
resource "aws_key_pair" "k8s" {
  key_name   = "k8s"
  public_key = file(var.PUBLIC_KEY_PATH)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "controller" {
  count                       = "${length(var.controller_ips)}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.k8s.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.k8s.id}"]
  instance_type               = "t2.micro"
  private_ip                  = "${var.controller_ips[count.index]}"
  user_data                   = "name=controller-${count.index}"
  subnet_id                   = "${aws_subnet.k8s.id}"
  source_dest_check           = false

  tags = {
    Name = "controller-${count.index+1}"
  }
}

resource "aws_instance" "worker" {
  count                       = "${length(var.worker_ips)}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.k8s.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.k8s.id}"]
  instance_type               = "t2.micro"
  private_ip                  = "${var.worker_ips[count.index]}"
  user_data                   = "name=worker-${count.index+1}|pod-cidr=${var.worker_pod_cidrs[count.index]}"
  subnet_id                   = "${aws_subnet.k8s.id}"
  source_dest_check           = false

  tags = {
    Name = "worker-${count.index+1}"
  }
}

locals {
  worker_hostnames     = "${split(",", replace(join(",", aws_instance.worker.*.private_dns), ".${var.region}.compute.internal", ""))}"
  controller_hostnames = "${split(",", replace(join(",", aws_instance.controller.*.private_dns), ".${var.region}.compute.internal", ""))}"
}

resource "null_resource" "k8s_controller_bootstrap" {
  # Terraform does not allow to use `length` function on computed list
  # count = "${length(aws_instance.controller.*.id)}"
  count = "${length(var.controller_ips)}"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PRIV_KEY_PATH)
    host        = "${element(aws_instance.controller.*.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [ "mkdir -p /home/ubuntu/k8s-scripts" ]
  }

  provisioner "file" {
    source      = "scripts/k8s-bootstrap-machines.sh"
    destination = "/home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh"
  }

  provisioner "file" {
    source      = "scripts/k8s-start-controller.sh"
    destination = "/home/ubuntu/k8s-scripts/k8s-start-controller.sh"
  }

  provisioner "file" {
    source      = "scripts/k8s-metrics-server-v0.5.2-components.yaml"
    destination = "/home/ubuntu/k8s-scripts/k8s-metrics-server-v0.5.2-components.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh",
      "/home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/k8s-scripts/k8s-start-controller.sh",
      "/home/ubuntu/k8s-scripts/k8s-start-controller.sh"
    ]
  }
}

resource "null_resource" "k8s_worker_bootstrap" {
  count = "${length(var.worker_ips)}"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PRIV_KEY_PATH)
    host        = "${element(aws_instance.worker.*.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [ "mkdir -p /home/ubuntu/k8s-scripts" ]
  }

  provisioner "file" {
    source      = "scripts/k8s-bootstrap-machines.sh"
    destination = "/home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh",
      "/home/ubuntu/k8s-scripts/k8s-bootstrap-machines.sh"
    ]
  }
}

output "controller_instance_ips" {
  value = aws_instance.controller.*.public_ip
}

output "worker_instance_ips" {
  value = aws_instance.worker.*.public_ip
}
