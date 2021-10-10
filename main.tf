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
/*resource "aws_key_pair" "key-ks8" {
    key_name = "key-ks8"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSTGANtfmtE7rYtOoekCrhZ2S6lrRzFAiT5uFu58cVc88/zD65i0UiycFG/Z3TAt7Fp/39dTN64nCsC66LETjgC4uZKYSg8RslmMoHCf+oLLla5NsidffVfchl2oyh0wh5nq9xVtftfYF81wyUKG21rA3nKSFT8fyfBJJJDhOl2Ebw7ljQmRack8WJWArPYJ2F5mxFeiUb7hCb3C7Dh7kzrKxtIiCrFJ0U5dQsJkXOr5gE/HYY2FDuW7x/rB+YSgEmKnDfmr+fXolQHwCWz3pwe2PSsSxgqE+IhFcI7mV0mg877y57WkkeafpJWVMGQ/cD7iIVB8LbFfacKp3DV7ICzTS/nIPddMaPlEzEMJCvKvFbouPMCkRIkLFvJWjEggeUeA8loX3oc3M69yD4uSfeR4aZvxW7CbZrTQnxSdWVwqeH+cRu3+JvG6Ne3L+3ksiZ0XqV2aEp8wmmn92+FIDMKl3bVd48OL1xxDMWAltE1sQuPwF8t/Y11mAZMAOwS1M= raphael@DESKTOP-QT3IKI6"   
}*/

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