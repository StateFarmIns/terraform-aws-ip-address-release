variable "account_name" {
  type        = string
  description = "The account name for use in alarm description."
}

variable "prefix" {
  type        = string
  description = "prefix name, can be a team or product name. E.g., 'SRE'"
}

variable "timeout" {
  type        = number
  description = "Timeout value for the lambda"
  default     = 300
}

variable "lambda_runtime" {
  type        = string
  description = "Python runtime to use for this lambda"
  default     = "python3.9"
}

variable "permissions_boundary_arn" {
  type        = string
  default     = null
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM roles."
}

variable "iam_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM Role to use (creates a new one if set to `null`)"
}

variable "internet_egress_security_group_id" {
  type        = string
  description = "security group id that allows internet outbound calls to port 443"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to attach the IP Address Release lambda to."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets that Lambda will be created with in the VPC"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the key to give to Lambda for access"
}
