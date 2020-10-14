// Building an Instance

// Building key pair for AWS Instance
resource "aws_key_pair" "key_pair_pem" {
  key_name   = "grafana_key_pair"
  public_key = file(var.public_key)
}

resource "aws_instance" "grafana-instance" {
  ami           = var.ami
  instance_type = var.instance
  key_name      = aws_key_pair.key_pair_pem.key_name
  vpc_security_group_ids = [
    aws_security_group.grafana-web.id,
    aws_security_group.grafana-ssh.id,
    aws_security_group.grafana-egress-tls.id,
    aws_security_group.grafana-icmp.id,
	aws_security_group.grafana-web-server.id
  ]

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  connection {
    type = "ssh"
    host = self.public_ip
    private_key = file(var.private_key)
    user        = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get remove docker docker-engine docker.io containerd runc -y",
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo apt-key fingerprint 0EBFCD88",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io",
      "sudo docker run hello-world",
      "mkdir /opt/monitoring",
      "docker network create monitoring",
      "docker volume create grafana-volume",
      "docker volume create influxdb-volume",
      "docker run --rm -e INFLUXDB_DB=$INFLUXDB_DB -e INFLUXDB_ADMIN_ENABLED=$INFLUXDB_ADMIN_ENABLED -e INFLUXDB_ADMIN_USER=$INFLUXDB_ADMIN_USER -e INFLUXDB_ADMIN_PASSWORD=$INFLUXDB_ADMIN_PASSWORD -e INFLUXDB_USER=$INFLUXDB_USER -e INFLUXDB_USER_PASSWORD=$INFLUXDB_USER_PASSWORD -v influxdb-volume:/var/lib/influxdb influxdb /init-influxdb.sh",
      "docker-compose up -d"
    ]
  }

  tags = {
    Name     = "grafana-instance"
    Location = "N.Virginia"
  }

}

resource "aws_security_group" "grafana-ssh" {
  name        = "grafana-ssh-group"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "grafana-ssh-vpc"
  }
}

resource "aws_security_group" "grafana-web" {
  name        = "grafana-web-group"
  description = "Security group for WAN traffic"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "grafana-web-vpc"
  }
}

resource "aws_security_group" "grafana-egress-tls" {
  name        = "grafana-egress-tls"
  description = "Security group that allows inbound and outbound traffic from all instances in the VPC"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "grafana-egress-tls-vpc"
  }
}

resource "aws_security_group" "grafana-icmp" {
  name        = "grafana-icmp"
  description = "Security group to ping instance"
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "grafana-icmp-vpc"
  }
}

resource "aws_security_group" "grafana-web-server" {
  name        = "grafana-web-server"
  description = "Security group open port 3000"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grafana-web-server-vpc"
  }
}

resource "aws_security_group" "grafana-influx-server" {
  name        = "grafana-influx-server"
  description = "Security group open port 8086"
  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grafana-web-server-vpc"
  }
}