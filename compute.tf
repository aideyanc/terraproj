/*
# Create varnish AMI
resource "aws_ami" "varnish_ami" {
  name                = "ampdev_varnish_ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 10
    volume_type = "gp2"
    encrypted = true
    delete_on_termination = true
  }

user_data = file("install_varnish.sh")
}
*/

# create varnish instance
data "aws_ami" "varnish_instance" {
  executable_users = ["self"]
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220426.0-x86_64-gp2.*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "varnish_instance" {
  ami = data.aws_ami.varnish_instance.id
  instance_type = var.ec2_instance_type["varnish"]
  key_name = var.key_name
  user_data = file("install_varnish.sh")
}