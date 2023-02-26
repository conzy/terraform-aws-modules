data "aws_caller_identity" "current" {}

## Config
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.id
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_delivery_channel" "this" {
  name           = aws_config_configuration_recorder.this.id
  s3_bucket_name = var.config_bucket_name
}

resource "aws_config_configuration_recorder" "this" {
  name     = "config"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

## IAM
resource "aws_iam_role" "config" {
  name               = "config"
  assume_role_policy = data.aws_iam_policy_document.config.json
}

data "aws_iam_policy_document" "config" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "config_policy" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]

    resources = ["arn:aws:s3:::${var.config_bucket_name}"]
  }

  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::${var.config_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config" {
  role        = aws_iam_role.config.id
  policy      = data.aws_iam_policy_document.config_policy.json
  name_prefix = "config_"
}
