# Create EFS file system
resource "aws_efs_file_system" "o4bproject_efs" {
  creation_token = "AmpDevO4b_efs"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "AmpDevO4b_efs"
    Environment = "dev"
  }
}

# Create EFS mount target for each subnet
resource "aws_efs_mount_target" "o4bproject_efs_private_mount_target" {
  count           = var.item_count
  file_system_id  = aws_efs_file_system.o4bproject_efs.id
  subnet_id       = aws_subnet.o4bproject-private[count.index].id
  security_groups = [aws_security_group.o4bproject_efs_sg.id, aws_security_group.o4bproject_dev_ec2_private_sg.id]
}
