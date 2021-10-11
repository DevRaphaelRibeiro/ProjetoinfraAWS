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

# Create rotas
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

  subnets = [aws_subnet.default.id]
  security_groups = [aws_security_group.elb.id]
  instances  = [aws_instance.web.id]

  listener  {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}


# Create Instancia EC2
resource  "aws_instance"  "web" {
  
    


  connection  {
    type  = "ssh"
    user  = "ubuntu"
    host  = self.public_ip
  }
  instance_type = "t2.micro"

  ami = var.aws_amis[var.aws_region]

  

  vpc_security_group_ids  = [aws_security_group.default.id] 
  
  subnet_id = aws_subnet.default.id

}



