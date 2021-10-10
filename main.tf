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

resource "aws_security_group" "k8s-sg" {
    
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = true
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        /*cidr_blocks = ["0.0.0.0./0"]*/ 
    }
    egress  {
        cidr_blocks = [ "0.0.0.0/0" ]
        from_port = 0
        to_port = 0
        protocol = "-1"

    }
    
    
}

resource "aws_instance" "kubernetes-worker" {
    ami = "ami-03d5c68bab01f3496"
    instance_type = "t2.micro"
    key_name = "key-ssh"
    count = 2
    tags = {
        name = "k8s"
        type = "worker"
    }
    security_groups = ["${aws_security_group.k8s-sg.name}"]

  
}
resource "aws_instance" "kubernetes-master" {
    ami = "ami-03d5c68bab01f3496"
    instance_type = "t2.micro"
    key_name = "key-ssh"
    count = 1
    tags = {
      name = "k8s"
      type = "master"
    }
    security_groups = ["${aws_security_group.k8s-sg.name}"]
  
}