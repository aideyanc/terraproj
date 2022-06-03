# Create EFS file system
resource "aws_efs_file_system" "o4bproject_efs" {
  creation_token = "o4bproject_efs"

  tags = {
    Name        = "o4bproject_efs"
    Environment = "dev"
  }
}

# Create EFS mount target for each subnet
resource "aws_efs_mount_target" "o4bproject_efs_private_mount_target" {
  file_system_id  = aws_efs_file_system.o4bproject_efs.id
  subnet_id       = [aws_subnet.o4bproject-private[0].id][aws_subnet.o4bproject-private[1].id]
  security_groups = [aws_security_group.o4bproject_efs_sg.id, aws_security_group.o4bproject_dev_ec2_private_sg.id]
}

resource "aws_efs_mount_target" "o4bproject_efs_public_mount_target" {
  file_system_id  = aws_efs_file_system.o4bproject_efs.id
  subnet_id       = [aws_subnet.o4bproject-public[0].id][aws_subnet.o4bproject-public[1].id]
  security_groups = [aws_security_group.o4bproject_efs_sg.id]
}