variable "region" {
  description = "define what region the instance will be deployd"
  default     = "sa-east-1"
}
# Ubuntu Precise (x64)
variable "aws_amis" {
  default = {
    sa-east-1 = "ami-054a31f1b3bf90920"
    
    
  }
}

variable  "aws_region" {
  description = "AWS region to launch servers"
  default = "sa-east-1"
}

