module "cloudtrail" {
  source            = "../cloudtrail_org"
  cloudtrail_bucket = var.cloudtrail_bucket
}

# The management account requires these be enabled. i.e they will not be enabled automatically by the delegated
# administrator and organization Security Hub / GuardDuty
resource "aws_securityhub_account" "this" {}

resource "aws_guardduty_detector" "this" {
  enable = true
}
