variable "region" {
  default = "us-east-1"
  type    = string
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
  type    = string
}

variable "subnet_cidr" {
  default = "10.1.0.0/24"
  type    = string
}

variable "subnet_az" {
  default = "us-east-1a"
  type    = string
}