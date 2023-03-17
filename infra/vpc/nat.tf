resource "aws_security_group" "nat-sg" {
  ingress = [{
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
    description      = "same vpc allow"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SSH allow"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "alow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.vpc_name}-nat-instance-sg"
  }
}

resource "aws_instance" "NAT-Instance" {
  # count = "${length(var.region_azs)}"
  count                  = 1
  ami                    = var.ubuntu_ami.id
  instance_type          = "t4g.micro"
  availability_zone      = var.region_azs[count.index]
  iam_instance_profile   = var.ec2_instance_profile
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnets[count.index].id
  source_dest_check      = false
  vpc_security_group_ids = [aws_security_group.nat-sg.id]
  user_data              = <<-EOF
                          #!/bin/bash
                          echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
                          sysctl -p /etc/sysctl.conf
                          nic=$(ip a | grep BROADCAST | awk '{print $2}' | cut -c 1-4)
                          iptables -t nat -A POSTROUTING -o $nic -j MASQUERADE
                          iptables-save | tee /etc/iptables.sav
                          echo "iptables-restore < /etc/iptables.sav" >> /etc/rc.local
                          EOF
  tags = {
    "Name" = "${var.vpc_name}-nat-instance-${substr(var.region_azs[count.index], -1, 1)}"
  }
}
