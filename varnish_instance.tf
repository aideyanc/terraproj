/*
resource "aws_instance" "o4bproject_varnish_instance" {
  ami               = data.aws_ami.launch_configuration_ami.id
  instance_type     = var.ec2_instance_type["varnish"]
  availability_zone = [var.private_subnet_availability_zone]
  subnet_id         = [aws_subnet.o4bproject-private[0].id][aws_subnet.o4bproject-private[1].id]
  security_groups   = [aws_security_group.o4bproject_dev_ec2_private_sg.id]

  user_data = file("install_varnish.sh")

  tags = {
    Name        = "o4bproject-varnish-instance"
    Environment = "dev"
  }
}
*/