// Building an Instance

// Building key pair for AWS Instance
resource "aws_key_pair" "key_pair_pem" {
  key_name   = "grafana_key_pair"
  public_key = file(var.public_key)
}
// Creating EC2 instanse for Grafana and InfluxDB
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
  // Delivering docker-compose file
  provisioner "file" {
    source      = "files/docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }

  // Configuring packages and containers on remote host // DB Test curl -sL -I localhost:8086/ping // 
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get remove docker docker-engine docker.io containerd runc -y",
      "sudo apt-get update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo apt-key fingerprint 0EBFCD88",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
      "sudo apt-get install docker-compose -y",
      "sudo docker run hello-world",
      "sudo docker network create monitoring",
      "sudo docker volume create grafana-volume",
      "sudo docker volume create influxdb-volume",
      "sudo docker run --rm --env INFLUXDB_DB=${var.influxdb_db} --env INFLUXDB_ADMIN_ENABLED=true --env INFLUXDB_ADMIN_USER=${var.influxdb_admin_user} --env INFLUXDB_ADMIN_PASSWORD=${var.influxdb_admin_password} --env INFLUXDB_USER=${var.influxdb_user} --env INFLUXDB_USER_PASSWORD=${var.influxdb_user_password} -v influxdb-volume:/var/lib/influxdb influxdb /init-influxdb.sh | grep INFL",
      "sudo docker-compose -f /tmp/docker-compose.yml up -d"
    ]
  }

  tags = {
    Name     = "grafana-instance"
    Location = "N.Virginia"
  }
}

resource "aws_security_group" "grafana-ssh" {
  name        = "grafana-ssh-group"
  description = "Security group for SSH "
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
  description = "Security group for http/https traffic"
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
  description = "Security group for grafana interface and influxdb server"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
