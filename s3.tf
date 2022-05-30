# Create log bucket for Outer Load balancer

resource "aws_s3_bucket" "o4bproject_outer_lb_bucket" {
  bucket = "o4bproject-outer-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_outer_lb_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "o4bproject_outer_lb_log_bucket" {
  bucket = "o4bproject-outer-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_outer_lb_log_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "o4bproject_outer_lb_bucket_logs" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_log_bucket.id

  target_bucket = aws_s3_bucket.o4bproject_outer_lb_log_bucket.id
  target_prefix = "log/"
}


# Create log bucket for Inner Load balancer

resource "aws_s3_bucket" "o4bproject_inner_lb_bucket" {
  bucket = "o4bproject-inner-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_inner_lb_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "o4bproject_inner_lb_log_bucket" {
  bucket = "o4bproject-inner-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_inner_lb_log_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "o4bproject_inner_lb_bucket_logs" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_log_bucket.id

  target_bucket = aws_s3_bucket.o4bproject_inner_lb_log_bucket.id
  target_prefix = "log/"
}