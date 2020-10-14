variable "dynamo_db_table_name" {
  default = "nginx-locks-2"
}

variable "profile" {
  default = "nginx-user"
}

variable "region" {
  default = "us-east-1"
}

variable "instance" {
  default = "t2.nano"
}

variable "public_key" {
  default = "~/.ssh/ec2_key_pair.pub"
}

variable "private_key" {
  default = "~/.ssh/ec2_key_pair.pem"
}

variable "ami" {
  default = "ami-0817d428a6fb68645"
}