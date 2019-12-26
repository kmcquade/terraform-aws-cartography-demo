module "network" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v2.7.0"

  name = module.network_label.id
  cidr = var.vpc_cidr
  azs  = var.subnet_azs

  enable_nat_gateway                 = true
  enable_vpn_gateway                 = true
  propagate_public_route_tables_vgw  = true
  propagate_private_route_tables_vgw = true
  create_database_subnet_group       = false
  enable_dhcp_options                = true
  enable_dns_hostnames               = true
  enable_dns_support                 = true
  enable_s3_endpoint                 = true
  tags                               = var.default_tags
  public_subnet_tags                 = map("subnet-type", "public")
  create_vpc                         = var.create_vpc
  public_subnet_suffix               = "public-subnet"
  public_subnets                     = var.public_subnet_cidrs
}

resource "aws_security_group" "external" {
  vpc_id      = module.network.vpc_id
  name        = module.security_group_label.id
  description = "Allow ingress from authorized IPs to self, and egress to everywhere."
  tags        = module.security_group_label.tags
}


resource "aws_security_group_rule" "internal_ingress_all_self" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.external.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "external_ingress_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = 22
  cidr_blocks       = var.allowed_inbound_cidr_blocks
  type              = "ingress"
}

resource "aws_security_group_rule" "external_ingress_443" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = var.allowed_inbound_cidr_blocks
}

# HTTPS
resource "aws_security_group_rule" "external_ingress_7473" {
  from_port         = 7473
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = 7473
  type              = "ingress"
  cidr_blocks       = var.allowed_inbound_cidr_blocks
}

# HTTP
resource "aws_security_group_rule" "external_ingress_7474" {
  from_port         = 7474
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = 7474
  type              = "ingress"
  cidr_blocks       = var.allowed_inbound_cidr_blocks
}

# BOLT
resource "aws_security_group_rule" "external_ingress_7687" {
  from_port         = 7687
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = 7687
  type              = "ingress"
  cidr_blocks       = var.allowed_inbound_cidr_blocks
}

resource "aws_security_group_rule" "external_egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.external.id
  cidr_blocks       = ["0.0.0.0/0"]
}

