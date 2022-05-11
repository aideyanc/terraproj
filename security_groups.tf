# Create security group for the dev environment
resource "aws_security_group" "o4bproject_dev_sg" {
  name        = "o4bproject-dev-sg"
  description = "security group for the o4bproject development environment"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["3.11.244.82/32", "5.148.137.82/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "o4bproject-dev-sg"
    Environment = "dev"
  }
}


# Create security group for outer ALB
resource "aws_security_group" "o4bproject_outer_alb" {
  name        = "o4bproject-outer-alb-sg"
  description = "Security group for outer alb"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    cidr_blocks = ["3.11.244.82/32", "5.148.137.82/32"]
    description = "Allow inbound traffic from these IPs on the load balancer https listener port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["3.11.244.82/32", "5.148.137.82/32"]
    description = "Allow inbound traffic from these IPs on the load balancer http listener port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    description     = "Allow all outbound traffic to instances on the load balancer listener port"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bprocject-outer-alb-sg"
    Environment = "dev"
  }
}

# Create security group for inner ALB
resource "aws_security_group" "o4bprocject_inner_alb" {
  name        = "o4bprocject-inner-alb-sg"
  description = "Security group for inner alb"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    description = "Allow all inbound traffic on the load balancer http listener port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Allow outbound traffic to instances on the load balancer listener port"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bproject-inner-alb-sg"
    Environment = "dev"
  }
}

# Create security group for EC2 Instances
resource "aws_security_group" "o4bproject_ec2" {
  name        = "o4bproject-ec2-sg"
  description = "Security group rules for o4bproject EC2"
  vpc_id      = aws_vpc.o4bproject.id

  tags = {
    Name        = "o4bproject-ec2-sg"
    Environment = "dev"
  }
}

# Create security group and rule for RDS
resource "aws_security_group" "o4bproject_rds_sg" {
  name        = "o4bproject-rds-sg"
  description = "Security group rule for o4bproject-rds"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    description     = "Allow all inbound traffic to MySQL port from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bproject-rds-sg"
    Environment = "dev"
  }
}

# Create security group for redis cluster
resource "aws_security_group" "o4bproject_redis_sg" {
  name        = "o4bproject-redis-sg"
  description = "Security group rules for redis cluster"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    description     = "Allow all inbound traffic to redis port from EC2"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bproject-redis-sg"
    Environment = "dev"
  }
}


# Create security group for EFS
resource "aws_security_group" "o4bproject_efs_sg" {
  name        = "o4bproject-efs-sg"
  description = "Security group rules for o4bproject-EFS"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    description     = "Allow all inbound traffic to EFS port from EC2"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  egress {
    description     = "Allow all outbound traffic to EC2 port from EFS"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bproject-efs-sg"
    Environment = "dev"
  }
}


# Create security group for Elasticsearch
resource "aws_security_group" "o4bproject_elk_sg" {
  name        = "o4bproject-elk-sg"
  description = "Security group rules for o4bproject-ELK"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    description     = "Allow all inbound traffic to ELK port from EC2"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  egress {
    description     = "Allow all outbound traffic to EC2 port from ELK"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.o4bproject_ec2.id]
  }

  tags = {
    Name        = "o4bproject-elk-sg"
    Environment = "dev"
  }
}

# Create security group rules
resource "aws_security_group_rule" "o4bproject_ec2_https_out" {
  type              = "egress"
  description       = "Allow outbound traffic on the instance https port"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.o4bproject_ec2.id
}

resource "aws_security_group_rule" "o4bproject_ec2_http_out" {
  type              = "egress"
  description       = "Allow outbound traffic on the instance https port"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.o4bproject_ec2.id
}

resource "aws_security_group_rule" "o4bproject_ec2_http_in_ec2" {
  type                     = "ingress"
  description              = "Allow all inbound traffic from ec2 on http port"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.o4bproject_ec2.id
  security_group_id        = aws_security_group.o4bproject_ec2.id
}

resource "aws_security_group_rule" "o4bproject_ec2_http_outer" {
  type                     = "ingress"
  description              = "Allow all inbound traffic from the load balancer on http port"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.o4bproject_outer_alb.id
  security_group_id        = aws_security_group.o4bproject_ec2.id
}

resource "aws_security_group_rule" "o4bproject_ec2_http_inner" {
  type                     = "ingress"
  description              = "Allow all inbound traffic from the load balancer on http port"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.o4bprocject_inner_alb.id
  security_group_id        = aws_security_group.o4bproject_ec2.id
}

resource "aws_security_group_rule" "o4bprocject_ec2_mysql_out" {
  type                     = "egress"
  description              = "Allow outbound traffic on the instance Mysql port"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.o4bproject_rds_sg.id
  security_group_id        = aws_security_group.o4bproject_ec2.id
}

