
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
    region = "eu-central-1"
    access_key = "AKIA4JBXL4JTE6NCC6NP"
    secret_key = "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"

    default_tags {
        tags = {
            Owner = "Guy"
        }
    }
}

# Configure vpc
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Configure Internet Gateway
resource "aws_internet_gateway" "first-gateway" {
  vpc_id = aws_vpc.first-vpc.id
}

# Configure Custom Route Table
resource "aws_route_table" "first-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.first-gateway.id
  }

}

# Configure a Subnet 
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.first-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

}

# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.first-route-table.id
}

# Configure Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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

}

# Configure network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# Configure elastic IP
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.first-gateway]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# Configure Ubuntu server and install Docker
resource "aws_instance" "web-server-instance" {
  ami               = "ami-0caef02b518350c8b"
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name          = "guy-key-pair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install docker.io -y
                EOF
}
