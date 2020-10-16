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
  default = "~/.ssh/grafana_key_pair.pub"
}

variable "private_key" {
  default = "~/.ssh/grafana_key_pair.pem"
}

variable "ami" {
  default = "ami-0817d428a6fb68645"
}

variable "influxdb_db" {
  default = "terraform"
}
variable "influxdb_admin_user" {
  default = "admin"
}
variable "influxdb_admin_password" {
}
variable "influxdb_user" {
  default = "telegraf"
}
variable "influxdb_user_password" {
}