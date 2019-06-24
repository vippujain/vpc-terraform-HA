# Provider - which cloud i am using
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_key_pair" "default" {
  key_name = "vpctestkeypair"
  public_key = "${file("${var.key_path}")}"
}

# Define our VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "Test-VPC"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Test-VPC Public Subnet"
  }
}

# Define the public subnet2
resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr1}"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Test-VPC Public Subnet 2"
  }
}


# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Test-VPC Private Subnet"
  }
}

# Define the private subnet2
resource "aws_subnet" "private-subnet2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet_cidr1}"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Test-VPC Private Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Test-VPC IGW"
  }
}

# Define the route table
resource "aws_route_table" "public-RT" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }

  tags = {
    Name = "Test-VPC Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-RT" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-RT.id}"
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-RT2" {
  subnet_id = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.public-RT.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.main.id}"

  tags = {
    Name = "Web Server SG"
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "test" {
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.sgweb.id}"]
  key_name = "${aws_key_pair.default.id}"
  user_data = "${file("install.sh")}"
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "test" {
  launch_configuration = "${aws_launch_configuration.test.id}"
  vpc_zone_identifier       = ["${aws_subnet.public-subnet.id}"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.app.name}"]
  health_check_type = "ELB"

}

resource "aws_elb" "app" {
  /* Requiered for EC2 ELB only
    availability_zones = "${var.zones}"
  */
  name            = "test-elb"
  subnets         = ["${aws_subnet.public-subnet.id}"]
  security_groups = ["${aws_security_group.sgweb.id}"]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  cross_zone_load_balancing   = true
  idle_timeout                = 960  # set it higher than the conn. timeout of the backend servers
  connection_draining         = true
  connection_draining_timeout = 300
  tags = {
    Name = "test-elb-app"
    Type = "elb"
  }
}

resource "aws_security_group" "elb" {
    name = "test-elb"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.main.id}"
    tags = {
        Name        = "test-elb-security-group"
    }
}
