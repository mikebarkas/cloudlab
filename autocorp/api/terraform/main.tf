terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "cloudlab-terraform-state-mikebarkas"
    key          = "autocorp/api/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}

# Latest official Debian 12 image (Debian's AWS account)
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
}

# Create VPC
resource "aws_vpc" "auto-corp-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Internet gateway
resource "aws_internet_gateway" "auto-corp-gateway" {
  vpc_id = aws_vpc.auto-corp-vpc.id
}

# Create custom route table
resource "aws_route_table" "auto-corp-route-table" {
  vpc_id = aws_vpc.auto-corp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.auto-corp-gateway.id
  }
}

# Create a subnet
resource "aws_subnet" "auto-corp-subnet" {
  vpc_id            = aws_vpc.auto-corp-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone
}

# Associate subnet with route table
resource "aws_route_table_association" "rta" {
  route_table_id = aws_route_table.auto-corp-route-table.id
  subnet_id      = aws_subnet.auto-corp-subnet.id
}

# Create security group for ports: 22 (admin only), 80, 443
# The API listens on 8080 behind Caddy and is not exposed
resource "aws_security_group" "auto-corp-sg" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.auto-corp-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP for ACME challenge and redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from admin only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create network interface with IP in the subnet
resource "aws_network_interface" "auto-corp-nic" {
  subnet_id       = aws_subnet.auto-corp-subnet.id
  private_ips     = ["10.0.1.55"]
  security_groups = [aws_security_group.auto-corp-sg.id]
}

# Create server instance
resource "aws_instance" "auto-corp-ec2" {
  ami               = data.aws_ami.debian.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.auto-corp-nic.id
  }

  # Without this, a new Debian image would replace the instance on the next apply.
  # Replace it on purpose with: terraform apply -replace=aws_instance.auto-corp-ec2
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_ec2_instance_state" "auto-corp-api" {
  instance_id = aws_instance.auto-corp-ec2.id
  state       = "running"
}

# Allocate an Elastic IP
resource "aws_eip" "auto-corp-eip" {
  domain = "vpc"
}

# Associate the Elastic IP with the network interface
resource "aws_eip_association" "ip_assoc" {
  allocation_id        = aws_eip.auto-corp-eip.id
  network_interface_id = aws_network_interface.auto-corp-nic.id
  private_ip_address   = "10.0.1.55"

  # The VPC needs an internet gateway before an EIP can be associated
  depends_on = [aws_internet_gateway.auto-corp-gateway]
}
