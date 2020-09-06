provider "aws" {
  region = "us-east-2"
}

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "cactus-project"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "cactus-igw"
  }
}

# Public subnet 1
resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_cidr_01}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "public_subnet_01"
  }
}

#Public Route table for subnet 1
resource "aws_route_table" "public_route_01" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "cactus_public_rt_01"
  }
}

# Public subnet 1 RT association
resource "aws_route_table_association" "pub_subnet_rt_01" {
  subnet_id      = "${aws_subnet.public_subnet_01.id}"
  route_table_id = "${aws_route_table.public_route_01.id}"
}

# Public subnet 2
resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_cidr_02}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "public_subnet_02"
  }
}

#Public Route table for subnet 2
resource "aws_route_table" "public_route_02" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "cactus_public_rt_02"
  }
}

# Public subnet 2 RT association
resource "aws_route_table_association" "pub_subnet_rt_02" {
  subnet_id      = "${aws_subnet.public_subnet_02.id}"
  route_table_id = "${aws_route_table.public_route_02.id}"
}


# Private subnet 1
resource "aws_subnet" "private_subnet_01" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_cidr_01}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "private_subnet_01"
  }
}

# Private subnet 2
resource "aws_subnet" "private_subnet_02" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_cidr_02}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "private_subnet_02"
  }
}

# Private Route table
resource "aws_default_route_table" "private_route" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"
  tags = {
    Name = "default_route_table"
  }
}

# Private subnet 1 RT association
resource "aws_route_table_association" "pvt_subnet_rt_01" {
  subnet_id      = "${aws_subnet.private_subnet_01.id}"
  route_table_id = "${aws_default_route_table.private_route.id}"
}

# Private subnet 2 RT association
resource "aws_route_table_association" "pvt_subnet_rt_02" {
  subnet_id      = "${aws_subnet.private_subnet_02.id}"
  route_table_id = "${aws_default_route_table.private_route.id}"
}


# Security Group
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Test public access security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # allow all traffic to private SN
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cactus_sg"
  }
}
