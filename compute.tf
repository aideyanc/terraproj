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

# create varnish instance
resource "aws_instance" "varnish_instance" {
  ami = aws_ami.varnish_ami.id
  instance_type = var.instance_type[varnish]
  
}