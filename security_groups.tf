# Create security group for outer ALB
resource "aws_security_group" "o4bproject_outer_alb" {
  name        = "o4bproject-outer-alb-sg"
  description = "Security group for outer alb"
  vpc_id      = aws_vpc.o4bproject.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic on the load balancer https listener port"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic on the load balancer http listener port"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    description     = "Allow all outbound traffic to instances on the load balancer listener port"
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.o4bproject_ec2.id]
    to_port         = 80
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

# Create security group and rules for EC2
resource "aws_security_group" "o4bproject_ec2" {
  name        = "o4bproject-ec2-sg"
  description = "Security group rules for o4bproject EC2"
  vpc_id      = aws_vpc.o4bproject.id

  tags = {
    Name        = "o4bproject-ec2-sg"
    Environment = "dev"
  }
}

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

