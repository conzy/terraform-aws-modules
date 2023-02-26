variable "cloudtrail_bucket" {
  type        = string
  description = "The name of the cloudtrail bucket"
}

variable "retention" {
  type        = number
  description = "The number of days to retain Cloudwatch Logs for"
  default     = 180
}
