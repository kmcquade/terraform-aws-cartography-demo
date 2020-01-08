module "cartography_instance" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v2.12.0"

  name                        = module.cartography_label.id
  instance_count              = 1
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.small"
  key_name                    = var.key_name
  iam_instance_profile        = var.create_iam ? aws_iam_instance_profile.cartography[0].name : var.cartography_instance_profile_name
  subnet_id                   = module.network.public_subnets[0]
  user_data                   = data.template_file.cartography_userdata.rendered
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.external.id]

  tags = module.cartography_label.tags
}


module "kms_key" {
  source                  = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=0.4.0"
  namespace               = var.namespace
  stage                   = var.stage
  name                    = var.name
  description             = "KMS key for Cartography disk"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  alias                   = var.kms_key_alias
  tags                    = module.cartography_label.tags
}

resource "aws_ebs_volume" "cartography" {
  availability_zone = module.network.azs[0]
  size              = 20
  encrypted         = true
  kms_key_id        = module.kms_key.key_id
  tags              = module.cartography_label.tags
}


resource "aws_volume_attachment" "cartography" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.cartography.id
  instance_id = module.cartography_instance.id
}