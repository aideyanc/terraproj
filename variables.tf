variable "aws_region" {
  description = "AWS region of deployment"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "cidr block of VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_availability_zone" {
  description = "availability zone of private subnets"
  type        = string
  default     = "eu-west-1a"
}

variable "public_subnet_availability_zone" {
  description = "availability zone of public subnets"
  type        = string
  default     = "eu-west-1b"
}

variable "private_subnet_cidr_block" {
  description = "cidr block of private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_block" {
  description = "cidr block of public subnet"
  type        = string
  default     = "10.0.2.0/24"
}