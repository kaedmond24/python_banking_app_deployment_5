# Configure AWS Provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Create VPC 
resource "aws_vpc" "deploy5_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name : "deploy5_vpc"
    vpc : "deploy5"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.deploy5_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_deploy5.id
  }

  tags = {
    Name : "deploy5_public_rt"
    vpc : "deploy5"
  }
}

# Create Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.deploy5_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name : "public_subnet_a"
    vpc : "deploy5"
    az : "${var.region}a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.deploy5_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name : "public_subnet_b"
    vpc : "deploy5"
    az : "${var.region}b"
  }
}

resource "aws_internet_gateway" "igw_deploy5" {
  vpc_id = aws_vpc.deploy5_vpc.id

  tags = {
    Name : "igw_deploy5"
    vpc : "deploy5"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group
resource "aws_security_group" "deploy5_sg" {
  vpc_id      = aws_vpc.deploy5_vpc.id
  name        = "deploy5_sg"
  description = "open ssh jenkins traffic"

  tags = {
    Name : "deploy5_sg"
    vpc : "deploy5"
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Create Instance
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.deploy5_sg.id]
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_a.id
  #   associate_public_ip_address = "true"

  user_data = file("jenkins_deploy.sh")

  tags = {
    Name : "jenkins_server"
    vpc : "deploy5"
    az : "${var.region}a"
  }

}

resource "aws_instance" "application_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.deploy5_sg.id]
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_b.id
  #   associate_public_ip_address = "true"

  tags = {
    Name : "application_server"
    vpc : "deploy5"
    az : "${var.region}b"
  }

}

output "jenkins_server_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "application_server_public_ip" {
  value = aws_instance.application_server.public_ip
}
