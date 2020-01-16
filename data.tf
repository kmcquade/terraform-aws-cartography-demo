data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ec2_ami_name_filter]
  }

  owners = [var.ec2_ami_owner_filter]
}

data "template_file" "cartography_userdata" {
  template = file("${path.module}/templates/cartography-systemd.sh")
  vars = {
    neo4j_config        = data.template_file.neo4j_config.rendered
    cartography_user    = "cartography"
    cartography_version = "0.14.0"
    environment_file    = "/opt/cartography/etc/cartography.d/cartography.sh"
    aws_config_s3_path  = "s3://${aws_s3_bucket_object.cartography_config.bucket}/${aws_s3_bucket_object.cartography_config.key}"
  }
}

data "template_file" "neo4j_config" {
  template = file("${path.module}/templates/neo4j.conf")
}

