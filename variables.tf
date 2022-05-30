variable "aws_region" {
  description = "AWS region of deployment"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "cidr block of VPC"
  type        = string
}

variable "private_subnet_availability_zone" {
  description = "availability zone of private subnet"
  type        = string
  default     = "eu-west-1a"
}

variable "public_subnet_availability_zone" {
  description = "availability zone of public subnet"
  type        = string
  default     = "eu-west-1b"
}

variable "private_subnet_cidr_block" {
  description = "cidr block of private subnet"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "cidr block of public subnet"
  type        = string
}

variable "health_check" {
  description = "file path to log health checks"
  default     = "~/src/health_checks"
}

variable "ssl_policy" {
  description = "ssl policy for the certificate"
  default     = ""
}

variable "ec2_instance_type" {
  description = "Ec2 instance name and types"
  default = {
    varnish = ""
    Magento = ""
  }
}

variable "key_name" {
  description = "key pair for creating ec2 instances"
  default     = ""
}

variable "desired_capacity" {
  description = "desired instance capacity"
  default     = 1
}

variable "min_size" {
  description = "minimum number of instance to launch"
  default     = 1
}

variable "max_size" {
  description = "maximum number of instances to launch"
  default     = 2
}

variable "health_check_grace_period" {
  description = "Grace period for health checks"
  default     = 300
}

variable "health_check_type" {
  description = "type of health check"
  default     = "ELB"
}

variable "owners" {
  description = "AWS account owner's ID"
  default     = "834177416320"
}

variable "rds" {
  description = "Map rds configuration values"
  default = {
    db_name = "o4bproject-db"
    allocated_storage = 10
    max_allocated_storage = 20
    storage_encrypted = true
    engine = "mysql"
    engine_version = "5.7.0"
    instance_class = "db.c5d.2xlarge"
    username = ""
    password = ""
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot = true
    enable_deletion_protection = true
    backup_retention_period = "0"
    performance_insights_enabled = true
    copy_tags_to_snapshot = true
    multi_az = false
  }
  
}