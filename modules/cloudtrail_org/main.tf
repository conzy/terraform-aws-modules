data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "alias" {}
data "aws_region" "current" {}
data "aws_organizations_organization" "this" {}

resource "aws_cloudtrail" "organization_trail" {
  name                          = "conzy-demo"
  s3_bucket_name                = var.cloudtrail_bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.organization_trail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail.arn
}

resource "aws_cloudwatch_log_group" "organization_trail" {
  name              = "CloudTrail"
  retention_in_days = var.retention
}

resource "aws_iam_role" "cloudtrail" {
  name               = "cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_trust.json
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name_prefix = "cloudwatch_"
  policy      = data.aws_iam_policy_document.cloudtrail_cloudwatch.json
  role        = aws_iam_role.cloudtrail.name
}

data "aws_iam_policy_document" "cloudtrail_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogStream",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.organization_trail.id}:log-stream:${data.aws_caller_identity.current.account_id}_*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.organization_trail.id}:log-stream:${data.aws_organizations_organization.this.id}_*",
    ]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.organization_trail.id}:log-stream:${data.aws_caller_identity.current.account_id}_*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.organization_trail.id}:log-stream:${data.aws_organizations_organization.this.id}_*",
    ]
  }
}
