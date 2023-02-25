# Cloudtrail Logs for Organization Trail are stored here
module "cloudtrail_bucket" {
  source  = "app.terraform.io/conzy-demo/s3/aws"
  version = "0.0.2"
  name    = "cloudtrail"
}

# The S3 _access logs_ of the CloudTrail bucket are stored in this bucket.
module "cloudtrail_logs_bucket" {
  source       = "app.terraform.io/conzy-demo/s3/aws"
  version      = "0.0.2"
  disable_acls = false # Typically we disable ACLs on modern S3 configurations but we need the canned log delivery ACL
  name         = "cloudtrail-s3-logs"
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket" {
  bucket = module.cloudtrail_bucket.bucket_name
  policy = data.aws_iam_policy_document.cloudtrail_organization.json
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = module.cloudtrail_bucket.bucket_name
  target_bucket = module.cloudtrail_logs_bucket.bucket_name
  target_prefix = "cloudtrail/"
}

resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  bucket = module.cloudtrail_logs_bucket.bucket_name
  acl    = "log-delivery-write"
}

locals {
  trail_arn = "arn:aws:cloudtrail:${data.aws_region.current.name}:${var.management_account_id}:trail/${var.trail_name}"
}

data "aws_iam_policy_document" "cloudtrail_organization" {
  statement {
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.cloudtrail_bucket.bucket_arn]
    condition {
      test     = "StringEquals"
      values   = [local.trail_arn]
      variable = "aws:SourceArn"
    }
  }

  statement {
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    resources = [
      "${module.cloudtrail_bucket.bucket_arn}/AWSLogs/${data.aws_organizations_organization.this.id}/*",
      "${module.cloudtrail_bucket.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "${module.cloudtrail_bucket.bucket_arn}/AWSLogs/${var.management_account_id}/*",
    ]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    condition {
      test     = "StringEquals"
      values   = [local.trail_arn]
      variable = "aws:SourceArn"
    }
  }
}

# AWS Config.
module "config_bucket" {
  source  = "app.terraform.io/conzy-demo/s3/aws"
  version = "0.0.2"
  name    = "config"
}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = module.config_bucket.bucket_name
  policy = data.aws_iam_policy_document.config_organization.json
}


data "aws_iam_policy_document" "config_organization" {
  statement {
    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.config_bucket.bucket_arn]
    condition {
      test     = "StringEquals"
      values   = var.organization_accounts
      variable = "AWS:SourceAccount"
    }
  }

  statement {
    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:ListBucket"]
    resources = [
      module.config_bucket.bucket_arn,
    ]
    condition {
      test     = "StringEquals"
      values   = var.organization_accounts
      variable = "AWS:SourceAccount"
    }
  }

  statement {
    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:PutObject"]
    resources = [for account in var.organization_accounts : "${module.config_bucket.bucket_arn}/AWSLogs/${account}/*"]

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    condition {
      test     = "StringEquals"
      values   = var.organization_accounts
      variable = "AWS:SourceAccount"
    }
  }
}