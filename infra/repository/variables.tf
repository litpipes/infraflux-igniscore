variable "name" {
  type = string
}

variable "visibility" {
  type = string
  default = "private"
}

variable "container_provider" {
  type = string
  default = ""
}

variable "tf_api_secret" {
  type = string
}

variable "secrets" {
  type = list
}

variable "organization" {
  type = string
}

variable "aws_role_prefix" {
  type = string
  default = ""
}

variable "template" {
  type = string
  default = ""
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