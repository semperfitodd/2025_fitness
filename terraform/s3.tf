data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "site" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [module.cdn.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.site_s3_bucket.s3_bucket_arn}/*"]
  }
}

locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/ico"
    "jpg"  = "image/jpeg"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/octet-stream"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
  }

  static_html_directory = "../static_site/build/"
}

module "site_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket = local.domain_name

  attach_public_policy = true
  attach_policy        = true
  policy               = data.aws_iam_policy_document.site.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_object" "website_object" {
  for_each = fileset(local.static_html_directory, "**/*")

  bucket       = module.site_s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${local.static_html_directory}/${each.value}"
  etag         = filemd5("${local.static_html_directory}/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])

  tags = var.tags
}