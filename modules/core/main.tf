# Set the Account Alias which is convenient. We can also use it to construct resource names in the account.
resource "aws_iam_account_alias" "alias" {
  account_alias = var.name
}

# Don't allow any public objects in the account
resource "aws_s3_account_public_access_block" "account" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a terraform role
module "terraform_role" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                 = "4.4.0"
  trusted_role_arns       = var.trusted_role_arns
  create_role             = true
  role_name               = "terraform"
  role_requires_mfa       = false
  custom_role_policy_arns = var.custom_role_policy_arns
}
