data "template_file" "aws_config" {
  template = file("${path.module}/aws_config.ini")
}

module "cartography" {
  source                            = "../../"
  namespace                         = var.namespace
  stage                             = var.stage
  name                              = var.name
  cartography_instance_profile_name = var.cartography_instance_profile_name
  region                            = var.region
  key_name                          = var.key_name
  vpc_cidr                          = var.vpc_cidr
  public_subnet_cidrs               = var.public_subnet_cidrs
  subnet_azs                        = var.subnet_azs
  allowed_inbound_cidr_blocks       = var.allowed_inbound_cidr_blocks
  create_iam                        = var.create_iam
  create_vpc                        = true
  cartography_config_rendered       = data.template_file.aws_config.rendered
}

variable "namespace" {}
variable "stage" {}
variable "name" {}
variable "cartography_instance_profile_name" { default = "" }
variable "region" {}
variable "key_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" {}
variable "subnet_azs" {}
variable "allowed_inbound_cidr_blocks" {}
variable "create_iam" { default = "true" }
