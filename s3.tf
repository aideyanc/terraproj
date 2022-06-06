# Create log bucket for Outer Load balancer

resource "aws_s3_bucket" "o4bproject_outer_lb_bucket" {
  bucket = "o4bproject-outer-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_outer_lb_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id
  acl    = "private"
}
/*
resource "aws_s3_bucket" "o4bproject_outer_lb_log_bucket" {
  bucket = "o4bproject-outer-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_outer_lb_log_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_log_bucket.id
  acl    = "log-delivery-write"
}
*/
resource "aws_s3_bucket_logging" "o4bproject_outer_lb_bucket_logs" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id

  target_bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "allow_access_from_outer_lb" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_outer_lb.json
}

data "aws_iam_policy_document" "allow_access_from_outer_lb" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["410587888893"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.o4bproject_outer_lb_bucket.arn,
      "${aws_s3_bucket.o4bproject_outer_lb_bucket.arn}/*",
    ]
  }
}


# Create log bucket for Inner Load balancer

resource "aws_s3_bucket" "o4bproject_inner_lb_bucket" {
  bucket = "o4bproject-inner-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_inner_lb_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_bucket.id
  acl    = "private"
}
/*
resource "aws_s3_bucket" "o4bproject_inner_lb_log_bucket" {
  bucket = "o4bproject-inner-lb-bucket"
}

resource "aws_s3_bucket_acl" "o4bproject_inner_lb_log_bucket_acl" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_log_bucket.id
  acl    = "log-delivery-write"
}
*/
resource "aws_s3_bucket_logging" "o4bproject_inner_lb_bucket_logs" {
  bucket = aws_s3_bucket.o4bproject_inner_lb_bucket.id

  target_bucket = aws_s3_bucket.o4bproject_inner_lb_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "allow_access_from_inner_lb" {
  bucket = aws_s3_bucket.o4bproject_outer_lb_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_outer_lb.json
}

data "aws_iam_policy_document" "allow_access_from_inner_lb" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["410587888893"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.o4bproject_inner_lb_bucket.arn,
      "${aws_s3_bucket.o4bproject_inner_lb_bucket.arn}/*",
    ]
  }
}