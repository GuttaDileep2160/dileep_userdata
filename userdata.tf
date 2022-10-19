terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
#   backend "s3" {
#     bucket         = "dileep-webapp-demo"
#     key            = "dileep/terraform/remote/s3/terraform.tfstate"
#     region         = "ap-south-1"
#     dynamodb_table = "dynamodb-state-locking"

#   }
}
provider "aws" {
  # Configuration options
  region = "ap-south-1"

}

#creating the vpc infra
resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "demo_vpc"
  }
}

#creating the subnets
resource "aws_subnet" "subnet-1a" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-1a"
  }
}

resource "aws_subnet" "subnet-1b" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-1b"
  }
}






#creating Internet Gateway
resource "aws_internet_gateway" "Demo_IG" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo_IG"
  }
}


#creating route table
resource "aws_route_table" "webapp-route-table" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Demo_IG.id
  }

  tags = {
    Name = "webapp-route-table"
  }
}

#create route table association
resource "aws_route_table_association" "webapp-RT-association-1A" {
  subnet_id      = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.webapp-route-table.id
}

resource "aws_route_table_association" "webapp-RT-association-1B" {
  subnet_id      = aws_subnet.subnet-1b.id
  route_table_id = aws_route_table.webapp-route-table.id
}

#creating ec2 instance on our vpc and our subnet

resource "aws_instance" "frontend_server" {
  ami                   = "ami-062df10d14676e201"
  key_name               = "FirstKeyPair"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1a.id
  vpc_security_group_ids = [aws_security_group.allow_80_22.id]

  user_data              = "${file("webapp.sh")}"

  tags = {
    Name  = "terraform provided ec2"
    App   = "frontend"
    Owner = "dileep"
  }
}

#creating security group
resource "aws_security_group" "allow_80_22" {
  name        = "allow-port-22-and-port-80"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description = "allow port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "allow port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "allow port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_HTTP_SSH"
  }
}