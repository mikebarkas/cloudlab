terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket       = "cloudlab-terraform-state-mikebarkas"
    key          = "account/github-oidc/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the roles, as owner/name"
  type        = string
  default     = "mikebarkas/cloudlab"
}

locals {
  state_bucket = "cloudlab-terraform-state-mikebarkas"
}

# Trust tokens that GitHub Actions signs.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Role for `terraform plan` on pull requests.
# Only pull request runs from this repo can assume it.
resource "aws_iam_role" "github_plan" {
  name = "github-actions-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:pull_request"
        }
      }
    }]
  })
}

# Plan only reads resources
resource "aws_iam_role_policy_attachment" "github_plan_read_only" {
  role       = aws_iam_role.github_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# use_lockfile writes and deletes a .tflock object in the state bucket,
# even during plan
resource "aws_iam_role_policy" "github_plan_state_lock" {
  name = "terraform-state-lock"
  role = aws_iam_role.github_plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:DeleteObject"]
      Resource = "arn:aws:s3:::${local.state_bucket}/*.tflock"
    }]
  })
}

output "plan_role_arn" {
  description = "Role ARN for the plan workflow (role-to-assume)"
  value       = aws_iam_role.github_plan.arn
}
