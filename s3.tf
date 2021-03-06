resource "aws_s3_bucket" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket              = "${local.name}-${terraform.workspace}-static-assets"
  acl                 = "private"
  acceleration_status = "Enabled"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = var.cors_origins
    expose_headers  = [
      "ETag",
      "Cache-Conrol",
      "Content-Type"
    ]
    max_age_seconds = 3000
  }

  versioning {
    enabled = false
  }

  logging {
    target_bucket = local.logging_bucket
    target_prefix = "AWSLogs/${local.account_id}/S3/${local.name}-${terraform.workspace}-static-assets/"
  }

  // CloudFront unable to reach `aws:kms` - not supported yet (2018-07-10)
  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default {
  //        sse_algorithm = "aws:kms"
  //      }
  //    }
  //  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = merge(
    local.tags,
    {
      Name     = "${local.name} Static Assets"
      Security = "SSE:AWS"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/*data "aws_iam_policy_document" "s3" {
  count = var.bucket_domain_name == "" ? 1 : 0
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.main[0].arn,
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.main.iam_arn,
      ]
    }
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.main[0].arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.main.iam_arn,
      ]
    }
  }
}*/

resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "${aws_s3_bucket.main[0].id}-policy",
    "Statement": [
    {
      "Action": "s3:ListBucket",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.main.iam_arn}"
      },
      "Resource": "${aws_s3_bucket.main[0].arn}",
      "Sid": ""
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.main.iam_arn}"
      },
      "Resource": "${aws_s3_bucket.main[0].arn}/*",
      "Sid": ""
    }
  ]
}
POLICY
}

