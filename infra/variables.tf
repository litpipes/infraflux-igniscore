variable "tf_api_secret" {
  type = string
}

variable "organization" {
  type = string
}

variable "repositories" {
  type = map
}

variable "aws_role_prefix_dev" {
  type = string
  default = ""
}

variable "aws_role_prefix_prod" {
  type = string
  default = ""
}

variable "aws_account_id_dev" {
  type = string
  default = ""
}