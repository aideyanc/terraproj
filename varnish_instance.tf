resource "aws_instance" "o4bproject_varnish_instance" {
  ami           = data.aws_ami.launch_config_ami.id
  instance_type = var.ec2_instance_type["varnish"]
  availability_zone = var.private_subnet_availability_zone
  subnet_id = aws_subnet.o4bproject-private.id
  security_groups = [ aws_security_group.o4bproject_dev_ec2_private_sg.id ]

  user_data = <<EOF

  EOF
  tags = {
    Name = "o4bproject-varnish-instance"
    Environment = "dev"
  }
}