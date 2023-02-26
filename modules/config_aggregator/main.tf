resource "aws_config_configuration_aggregator" "organization" {
  depends_on = [aws_iam_role_policy_attachment.organization]

  name = "organization"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_org.arn
  }
}

resource "aws_iam_role" "config_org" {
  name               = "config_organization"
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

resource "aws_iam_role_policy_attachment" "organization" {
  role       = aws_iam_role.config_org.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
