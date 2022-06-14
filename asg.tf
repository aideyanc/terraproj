# Create launch configuration for Auto scaling group
data "aws_ami" "launch_configuration_ami" {
  most_recent = true
  owners      = var.owners

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create private launch configuration for Auto scaling group
resource "aws_launch_configuration" "o4bproject_ec2_private_launch_configuration" {
  image_id                    = data.aws_ami.launch_configuration_ami.id
  instance_type               = var.ec2_instance_type["magento"]
  key_name                    = var.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.o4bproject_ec2_iam_instance_profile.name
  security_groups             = [aws_security_group.o4bproject_dev_ec2_private_sg.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = 10
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<EOF

  EOF
}

# Create a launch template for the Auto scaling group
resource "aws_launch_template" "o4bproject_ec2_launch_template" {
  name = "ampdev-ec2-launch-template"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  disable_api_termination = true

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.o4bproject_ec2_iam_instance_profile.name
  }

  image_id = aws_ami.varnish_ami.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.ec2_instance_type["magento"]

  key_name = var.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  placement {
    availability_zone = var.private_subnet_availability_zone
  }

  vpc_security_group_ids = [aws_security_group.o4bproject_dev_ec2_private_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ampdev-ec2-launch-template"
      Environment = "dev"
    }
  }
  user_data = file("install_varnish.sh")
}

# Create Auto scaling group for private subnet
resource "aws_autoscaling_group" "o4bproject_private_asg" {
  name                      = "AmpDevO4b-private-asg"
  vpc_zone_identifier       = [aws_subnet.o4bproject-private[0].id, aws_subnet.o4bproject-private[1].id]
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  launch_configuration      = aws_launch_configuration.o4bproject_ec2_private_launch_configuration.name
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  load_balancers            = [aws_lb.o4bproject_inner_alb.arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "AmpDevO4b-private-asg"
  }
}

# Create autoscaling policy for scaleout
resource "aws_autoscaling_policy" "o4bproject_asg_scaleout_policy" {
  name                   = "AmpDevO4b-asg-scaleout-policy"
  autoscaling_group_name = aws_autoscaling_group.o4bproject_private_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Create autoscaling policy for scalein
resource "aws_autoscaling_policy" "o4bproject_asg_scalein_policy" {
  name                   = "AmpDevO4b-asg-scalein-policy"
  autoscaling_group_name = aws_autoscaling_group.o4bproject_private_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# Create cloudwatch alarm metric to execute ASG policy for scaleout
resource "aws_cloudwatch_metric_alarm" "o4bproject_asg_scaleout_alarm" {
  alarm_name          = "AmpDevO4b-asg-scaleout-alarm"
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
  alarm_name          = "AmpDevO4b-asg-scalein-alarm"
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