data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "alias" {}
data "aws_region" "current" {}
data "aws_organizations_organization" "this" {}
data "aws_guardduty_detector" "this" {}

# We need to remove the management account and security account from our list of member accounts for GuardDuty and
# Security Hub
locals {
  security_account_removed = setsubtract(toset(var.organization_accounts), toset([data.aws_caller_identity.current.account_id]))
  member_accounts          = setsubtract(local.security_account_removed, toset([var.management_account_id]))
}

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable = true
  detector_id = data.aws_guardduty_detector.this.id

  datasources {
    s3_logs {
      auto_enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
  }
}

# Guardduty in all accounts
resource "aws_guardduty_member" "members" {
  for_each    = local.member_accounts
  account_id  = each.key
  detector_id = data.aws_guardduty_detector.this.id
  email       = "conzymaher+demo@gmail.com"
  lifecycle {
    ignore_changes = [email, invite]
  }
}

# Security Hub in all accounts
resource "aws_securityhub_organization_configuration" "this" {
  auto_enable = true
}

resource "aws_securityhub_member" "members" {
  for_each   = local.member_accounts
  account_id = each.key
  email      = "conzymaher+demo@gmail.com"
  lifecycle {
    ignore_changes = [email, invite]
  }
}

# Config Aggregator

module "config_aggregator" {
  source = "../config_aggregator"
}
