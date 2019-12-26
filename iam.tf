# ---------------------------------------------------------------------------------------------------------------------
# Cartography Instance Profile
/*
Set up an AWS identity (user, group, or role) for Cartography to use.
Ensure that this identity has the built-in AWS SecurityAudit policy (arn:aws:iam::aws:policy/SecurityAudit) attached.
This policy grants access to read security config metadata.

Set up AWS credentials to this identity on your server, using a config and credential file.
*/
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy_attachment" "cartography" {
  count      = var.create_iam ? 1 : 0
  name       = "Cartography"
  roles      = [aws_iam_role.cartography[count.index].name]
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role" "cartography" {
  count              = var.create_iam ? 1 : 0
  name               = "Cartography"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "cartography" {
  count = var.create_iam ? 1 : 0
  name  = "Cartography"
  role  = aws_iam_role.cartography[count.index].name
}
