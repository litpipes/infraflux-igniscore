terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    tfe = {
      version = "~> 0.57.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0" 
    }
  }
}

provider "github" {
  owner = "${var.organization}"
}

provider "tfe" {
  token    = "${var.tf_api_secret}"
}

provider "aws" {
  region = "us-east-1"
}

module "repositories" {
    source = "./repository"
    for_each =   var.repositories
    name = each.key
    visibility = each.value.visibility
    tf_api_secret = var.tf_api_secret
    organization = var.organization
    secrets = each.value.secrets
    container_provider = try(each.value.container_provider, "")
    aws_role_prefix_dev = var.aws_role_prefix_dev
    aws_role_prefix_prod = var.aws_role_prefix_prod
    aws_account_id_dev = var.aws_account_id_dev
    template = try(each.value.template, "")
}
