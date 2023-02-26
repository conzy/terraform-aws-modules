variable "name" {
  type        = string
  description = "This is used to set the IAM Account Alias"
}

variable "trusted_role_arns" {
  type        = list(string)
  description = "A list of arns to trust. This is typically going to be a terraform user in the management account."
}

variable "custom_role_policy_arns" {
  type        = list(string)
  description = "A list of policies to attach to the terraform role. We default to admin for demo purposes."
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "config_bucket_name" {
  type        = string
  description = "The AWS Config bucket in a centralised account."
  default     = ""
}
