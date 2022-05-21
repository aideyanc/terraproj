# Create launch configuration for Auto scaling group
data "aws_ami" "launch_config_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Create private launch configuration for Auto scaling group
resource "aws_launch_configuration" "o4bproject_ec2_private_launch_configuration" {
  image_id                    = data.aws_ami.launch_config_ami.id
  instance_type               = var.ec2_instance
  key_name                    = var.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.o4bproject_ec2_iam_instance_profile.name
  security_groups             = [aws_security_group.o4bproject_dev_ec2_private_sg.id]

  user_data = <<EOF

  EOF
}

# Create Auto scaling group for private subnet
resource "aws_autoscaling_group" "o4bproject_private_asg" {
  name                      = "o4bproject-private-asg"
  vpc_zone_identifier       = [aws_subnet.o4bproject-private.id]
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  launch_configuration      = aws_launch_configuration.o4bproject_ec2_private_launch_configuration.name
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  load_balancers            = [aws_lb.o4bproject_inner_alb.name]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "o4bproject-private-asg"
  }
}

# Create autoscaling policy for scaleout
resource "aws_autoscaling_policy" "o4bproject_asg_scaleout_policy" {
  name                   = "o4bproject-asg-scaleout-policy"
  autoscaling_group_name = aws_autoscaling_group.o4bproject_private_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Create autoscaling policy for scalein
resource "aws_autoscaling_policy" "o4bproject_asg_scalein_policy" {
  name                   = "o4bproject-asg-scalein-policy"
  autoscaling_group_name = aws_autoscaling_group.o4bproject_private_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# Create cloudwatch alarm metric to execute ASG policy for scaleout
resource "aws_cloudwatch_metric_alarm" "o4bproject_asg_scaleout_alarm" {
  alarm_name          = "to4bproject-asg-scaleout-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.o4bproject_private_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.o4bproject_asg_scaleout_policy.arn]
}

# Create cloudwatch alarm metric to execute ASG policy for scalein
resource "aws_cloudwatch_metric_alarm" "o4bproject_asg_scalein_alarm" {
  alarm_name          = "to4bproject-asg-scalein-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.o4bproject_private_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.o4bproject_asg_scalein_policy.arn]
}