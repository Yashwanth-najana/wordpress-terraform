provider "aws" {
  region     = "us-east-1"
}

#creating VPC
resource "aws_vpc" "yashvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "yashvpc"
  }
}
#subnet_creation

resource "aws_subnet" "web-subnet1" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    name = "web-subnet1"
  }
}
resource "aws_subnet" "web-subnet2" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    name = "web-subnet2"
  }
}

resource "aws_subnet" "application-subnet1" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    name = "application-subnet1"
  }
}
resource "aws_subnet" "application-subnet2" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    name = "application-subnet2"
  }
}
resource "aws_subnet" "database-subnet1" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    name = "database-subnet1"
  }
}

resource "aws_subnet" "database-subnet2" {
  vpc_id                  = aws_vpc.yashvpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    name = "database-subnet2"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "yashigw" {
  vpc_id = aws_vpc.yashvpc.id
}
# Creating  route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.yashvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yashigw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Associating Route table
resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.web-subnet1.id
  route_table_id = aws_route_table.public-route-table.id
}

# Associating Route table
resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.web-subnet2.id
  route_table_id = aws_route_table.public-route-table.id
}
#creating security group

resource "aws_security_group" "securitygroup" {
  vpc_id = aws_vpc.yashvpc.id
  #inbound Rules
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
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "securitygroup"
  }
}

#creating 1st EC2 instance
resource "aws_instance" "wordpress" {
  ami                         = "ami-0166fe664262f664c"
  instance_type               = "t2.micro"
  key_name                    = "jyo"
  subnet_id                   = aws_subnet.web-subnet1.id
  vpc_security_group_ids      = [aws_security_group.securitygroup.id]
  associate_public_ip_address = true
  user_data                   = file("data.sh")
  tags = {
    Name = "wordpress"
  }
}
