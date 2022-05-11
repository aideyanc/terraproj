resource "aws_key_pair" "o4bproject-auth" {
  key_name   = "o4bproject-dev-key"
  public_key = file("~/.ssh/o4bproject-dev-key.pub")
}

