# Create EC2 service role
resource "aws_iam_role" "o4bproject_ec2_iam_role" {
  name = "AmpDevO4b-ec2-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
        }
      },
    ]
  })

  tags = {
    Name        = "AmpDevO4b-ec2-iam-role"
    Environment = "dev"
  }
}

# Create EC2 IAM role policy
resource "aws_iam_role_policy" "o4bproject_ec2_iam_role_policy" {
  name = "AmpDevO4b-ec2-iam-policy"
  role = aws_iam_role.o4bproject_ec2_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "autoscalinggroup:*",
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create EC2 IAM Instance profile
resource "aws_iam_instance_profile" "o4bproject_ec2_iam_instance_profile" {
  name = "AmpDevO4b-ec2-iam-instance-profile"
  role = aws_iam_role.o4bproject_ec2_iam_role.id
}

