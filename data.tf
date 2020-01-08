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
    CARTOGRAPHY_USER    = "cartography"
    CARTOGRAPHY_VERSION = "0.14.0"
    ENVIRONMENT_FILE    = "/opt/cartography/etc/cartography.d/cartography.sh"
  }
}

data "template_file" "neo4j_config" {
  template = file("${path.module}/templates/neo4j.conf")
}