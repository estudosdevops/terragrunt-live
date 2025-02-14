terragrunt_version_constraint = ">= 0.36"

remote_state {
  backend = "s3"

  config = {
    bucket         = "tfstates-${local.merged.env}-tg-store"
    key            = "${local.merged.provider}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.merged.aws_region
    encrypt        = true
    # dynamodb_table = "${local.merged.prefix}-${local.merged.name}-tg-state-lock"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

locals {
  merged = merge(
    try(yamldecode(file(find_in_parent_folders("global_values.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("extra_values.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("env_values.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("region_values.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("component_values.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("account.yaml"))), {}),
  )
  custom_tags = merge(
    try(yamldecode(file(find_in_parent_folders("global_tags.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("env_tags.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("region_tags.yaml"))), {}),
    try(yamldecode(file(find_in_parent_folders("component_tags.yaml"))), {}),

  )
  # full_name = "${local.merged.prefix}-${local.merged.name}"
}

generate "provider-aws" {
  path      = "provider-aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "provider_default_tags" {
      type = map
      default = {}
    }
    provider "aws" {
      region = "${local.merged.aws_region}"
      default_tags {
        tags = var.provider_default_tags
      }
    }
  EOF
}