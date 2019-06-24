variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/26"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.0.0/28"
}

variable "public_subnet_cidr1" {
  description = "CIDR for the public subnet"
  default = "10.0.0.16/28"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.0.32/28"
}

variable "private_subnet_cidr1" {
  description = "CIDR for the private subnet"
  default = "10.0.0.48/28"
}

variable "ami" {
  description = "Centos"
  default = "ami-00c79db59589996b9"
}

variable "instance_type" {
  description = "Amazon Linux AMI"
  default = "t2.micro"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/home/ec2-user/.ssh/id_rsa.pub"
}

variable "instance_count" {
 default = 1
 }

