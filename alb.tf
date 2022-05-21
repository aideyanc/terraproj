resource "aws_lb" "o4bproject_outer_alb" {
  name               = "o4bproject-outer-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.o4bproject_outer_alb.id]
  subnets            = [aws_subnet.o4bproject-public.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.o4bproject_outer_lb_logs.bucket
    prefix  = "o4bproject-outer-alb"
    enabled = true
  }

  tags = {
    Name        = "o4bproject-outer-alb"
    Environment = "dev"
  }
}

listener {
  instance_port     = 80
  instance_protocol = "HTTP"
  lb_port           = 80
  lb_protocol       = "HTTP"
}

health_check {
  healthy_threshold   = 5
  interval            = 30
  target              = "HTTP:80"
  timeout             = 10
  unhealthy_threshold = 5
}




resource "aws_lb" "o4bproject_inner_alb" {
  name               = "o4bproject-inner-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.o4bproject_inner_alb.id]
  subnets            = [aws_subnet.o4bproject-private.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.o4bproject_inner_lb_logs.bucket
    prefix  = "o4bproject-inner-alb"
    enabled = true
  }

  tags = {
    Name        = "o4bproject-inner-alb"
    Environment = "dev"
  }
}

listener {
  instance_port     = 80
  instance_protocol = "HTTP"
  lb_port           = 80
  lb_protocol       = "HTTP"
}

health_check {
  healthy_threshold   = 5
  interval            = 30
  target              = "HTTP:80"
  timeout             = 10
  unhealthy_threshold = 5
}

# Create target group for Outer Load Balancer
resource "aws_lb_target_group" "o4bproject_outer_alb_tg" {
  name     = "o4bproject-outer-alb-tg"
  port     = 80
  protocol = "http"
  vpc_id   = aws_vpc.o4bproject.id

  health_check {
    path = var.health_check
  }
}

# Create target group for Inner Load Balancer
resource "aws_lb_target_group" "o4bproject_inner_alb_tg" {
  name     = "o4bproject-inner-alb-tg"
  port     = 80
  protocol = "http"
  vpc_id   = aws_vpc.o4bproject.id

  health_check {
    path = var.health_check
  }
}
# Create http://listener for Outer Load Balancer - forward to varnish
resource "aws_lb_listener" "o4bproject_outer_alb_http" {
  depends_on = [
    aws_acm_certificate_validation.default
  ]
  load_balancer_arn = aws_lb.o4bproject_outer_alb.arn
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.o4bproject_outer_alb_tg.arn
  }
}

# Create https://listener for Outer Load Balancer - redirect to http://
resource "aws_lb_listener" "o4bproject_outer_alb_https" {
  depends_on = [
    aws_acm_certificate_validation.default
  ]
  load_balancer_arn = aws_lb.o4bproject_outer_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type = "redirect"
    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
    target_group_arn = aws_lb_target_group.o4bproject_outer_alb_tg.arn
  }
}