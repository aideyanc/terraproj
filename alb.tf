resource "aws_lb" "o4bproject_outer_alb" {
  name               = "AmpDevO4b-outer-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.o4bproject_outer_alb.id]
  subnets            = [aws_subnet.o4bproject-public[0].id, aws_subnet.o4bproject-public[1].id]

  enable_deletion_protection = false
/*
  access_logs {
    bucket  = aws_s3_bucket.o4bproject_outer_lb_bucket.id
    prefix  = "AmpDevO4b-outer-alb"
    enabled = true
  }
*/
  tags = {
    Name        = "AmpDevO4b-outer-alb"
    Environment = "dev"
  }
}

# Create target group for Outer Load Balancer
resource "aws_lb_target_group" "o4bproject_outer_alb" {
  name     = "AmpDevO4b-outer-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.o4bproject.id

  health_check {
    enabled             = true
    path                = var.health_check
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# Create http listener for Outer Load Balancer - forward to varnish
resource "aws_lb_listener" "o4bproject_outer_alb" {
  load_balancer_arn = aws_lb.o4bproject_outer_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.o4bproject_outer_alb.arn
  }
}

/*
# Create https listener for Outer Load Balancer 
resource "aws_lb_listener" "o4bproject_outer_alb_https" {
  depends_on = [
    aws_acm_certificate_validation.default
  ]
  load_balancer_arn = aws_lb.o4bproject_outer_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.default.arn    example.ampdev.co  or example2.ampdev.co *.ampdev.co

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
*/


resource "aws_lb" "o4bproject_inner_alb" {
  name               = "AmpDevO4b-inner-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.o4bproject_inner_alb.id]
  subnets            = [aws_subnet.o4bproject-private[0].id, aws_subnet.o4bproject-private[1].id]

  enable_deletion_protection = false
/*
  access_logs {
    bucket  = aws_s3_bucket.o4bproject_inner_lb_bucket.id
    prefix  = "AmpDevO4b-inner-alb"
    enabled = true
  }
*/

  tags = {
    Name        = "AmpDevO4b-inner-alb"
    Environment = "dev"
  }
}


# Create target group for Inner Load Balancer
resource "aws_lb_target_group" "o4bproject_inner_alb" {
  name     = "AmpDevO4b-inner-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.o4bproject.id

  health_check {
    enabled             = true
    path                = var.health_check
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# Create http listener for Inner Load Balancer - forward to varnish
resource "aws_lb_listener" "o4bproject_inner_alb" {
  load_balancer_arn = aws_lb.o4bproject_inner_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.o4bproject_inner_alb.arn
  }
}
