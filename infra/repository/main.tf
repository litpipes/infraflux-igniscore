resource "github_repository" "repository" {
  name        = var.name
  visibility = var.visibility

  dynamic "template"{
    for_each = [var.template]

    content {
      owner                = split("/", template.value)[0]
      repository           = split("/", template.value)[1]
      include_all_branches = false
    }
  }
}

resource "github_actions_secret" "repo_tf_api_token_secret" {
  repository       = github_repository.repository.name
  secret_name      = "TF_API_TOKEN"
  plaintext_value  = var.tf_api_secret
  depends_on = [github_repository.repository]
}

resource "github_actions_variable" "repo_tf_cloud_org_secret" {
  repository       = github_repository.repository.name
  variable_name      = "TF_CLOUD_ORGANIZATION"
  value  = var.organization
  depends_on = [github_repository.repository]
}

resource "github_actions_secret" "repo_aws_role_dev" {
  repository       = github_repository.repository.name
  secret_name      = "AWS_ROLE_DEV"
  plaintext_value  = "${var.aws_role_prefix_dev}/github"
  depends_on = [github_repository.repository]
}

resource "github_actions_secret" "repo_aws_role_prod" {
  repository       = github_repository.repository.name
  secret_name      = "AWS_ROLE_PROD"
  plaintext_value  = "${var.aws_role_prefix_prod}/github"
  depends_on = [github_repository.repository]
}

resource "github_actions_variable" "repo_tf_workspace_secret" {
  repository       = github_repository.repository.name
  variable_name      = "TF_WORKSPACE"
  value  = github_repository.repository.name
  depends_on = [github_repository.repository]
}

resource "tfe_workspace" "tf_workspace_dev" {
  name         = "${github_repository.repository.name}-dev"
  organization = var.organization
  depends_on = [github_repository.repository]
}

resource "tfe_workspace" "tf_workspace_prod" {
  name         = "${github_repository.repository.name}-prod"
  organization = var.organization
  depends_on = [github_repository.repository]
}


resource "tfe_variable" "aws_provider_auth_dev" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.tf_workspace_dev.id
}

resource "tfe_variable" "aws_provider_auth_prod" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.tf_workspace_prod.id
}

resource "tfe_variable" "aws_provider_role_arn_dev" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = "${var.aws_role_prefix_dev}/terraform"
  category     = "env"
  workspace_id = tfe_workspace.tf_workspace_dev.id
}

resource "tfe_variable" "aws_provider_role_arn_prod" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = "${var.aws_role_prefix_prod}/terraform"
  category     = "env"
  workspace_id = tfe_workspace.tf_workspace_prod.id
}

resource "aws_ecr_repository" "ecr_repository"{
  count        = (var.container_provider == "ECR") ? 1 : 0
  name                 = github_repository.repository.name
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "ecr_repository_policy_dev" {
  count        = (var.container_provider == "ECR") ? 1 : 0
  repository = github_repository.repository.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id_dev}:root"
        }
        Action = [
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
  depends_on = [aws_ecr_repository.ecr_repository]
}

resource "github_actions_variable" "repo_ecr_repository" {
  count        = (var.container_provider == "ECR") ? 1 : 0
  repository       = github_repository.repository.name
  variable_name      = "ECR_REPOSITORY"
  value  = github_repository.repository.name
  depends_on = [github_repository.repository]
}