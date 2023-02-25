variable "management_account_id" {
  type        = number
  description = "The AWS Account ID of the management account."
}

variable "trail_name" {
  type        = string
  description = "The name of the organization trail"
  default     = "conzy-demo"
}

variable "organization_accounts" {
  type        = list(string)
  description = "A list of all accounts in the Organization"
}