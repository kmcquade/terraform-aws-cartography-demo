module "cartography_label" {
  source       = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.4.0"
  namespace    = var.namespace
  stage        = var.stage
  name         = var.name
  attributes   = ["cartography"]
  delimiter    = var.delimiter
  convert_case = var.convert_case
  tags         = var.default_tags
  enabled      = "true"
}

module "network_label" {
  source       = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.4.0"
  namespace    = var.namespace
  stage        = var.stage
  name         = var.name
  delimiter    = var.delimiter
  convert_case = var.convert_case
  tags         = var.default_tags
  enabled      = "true"
}

module "security_group_label" {
  source       = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.4.0"
  namespace    = var.namespace
  stage        = var.stage
  name         = var.name
  attributes   = ["sg"]
  delimiter    = var.delimiter
  convert_case = var.convert_case
  tags         = var.default_tags
  enabled      = "true"
}