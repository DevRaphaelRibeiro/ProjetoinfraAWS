# Configure the AWS Provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.59.0"

    }
  }
}

provider "aws" {
  region = var.region

}
# Create VPC
resource "aws_vpc"  "default" {
  cidr_block = "10.0.0.0/16"

}

# Create Internet Gateway
resource  "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Create routes
resource "aws_route" "internet_access"{
  route_table_id  = aws_vpc.default.main_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id  = aws_internet_gateway.default.id
}

# Create subrede
resource  "aws_subnet"  "default" {
  vpc_id  = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create Security Group - ELB
resource  "aws_security_group"  "elb" {
  name  = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id  = aws_vpc.default.id
  
  # Http access from anywere
  ingress {
    from_port = 80
    to_port = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  # Outbound internet access.
  egress  {
    from_port = 0
    to_port = 0
    protocol  = "-1"
  }
}

# Create Security Group Default.
resource  "aws_security_group"  "default" {
  name  = "terraform_example"
  description = "Used in the terraform"
  vpc_id  = aws_vpc.default.id

  #SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port = 80
    to_port = 80
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Create ELB
resource "aws_elb"  "web" {
  name  = "terraform-example-elb"
  availability_zones = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]

    
  listener  {
    instance_port = 8000
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  /*listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = ""
  }*/

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      target              = "HTTP:8000/"
      interval            = 30

    
  }  
  instances                   = [aws_instance.web.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-example-elb"
  }
}

# Create Instancia EC2
resource "aws_instance" "web" {
    ami = "ami-054a31f1b3bf90920"
    instance_type = "t2.micro"
    
}



