# terraform-aws-cartography-demo

This module creates the infrastructure for Lyft's [Cartography](https://github.com/lyft/cartography#installation) in AWS.

> **Obligatory disclaimer**: This is meant to be a starting point / POC for anyone testing out Cartography. I made this for my own purposes. It is NOT meant for use in a production environment.

## Requirements

The following resources should already exist in your AWS environment:
* AWS SSH key pair
* Trust policies in target AWS accounts for Cartography to assume

## Instructions

* Go to the example

```bash
cd examples/single-account
```

* Set up your Terraform state config in `state.tf`
* Fill out the variables
* Make sure the `allowed_inbound_cidr_blocks` variable matches a CIDR range including your IP address, so it is not set to `0.0.0.0/0`
* Build it

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

* Go to that IP address in your web browser and suffix it with port 7474. Like this: http://1.2.3.4:7474

* It will bring you to the Neo4j database login. Enter `neo4j` as your username and password. Enjoy!


## Usage

```hcl
module "cartography" {
  source                            = "../../"
  namespace                         = "yourname"
  stage                             = "dev"
  name                              = "demo"
  cartography_instance_profile_name = ""
  region                            = "us-east-1"
  key_name                          = "kinnaird"
  vpc_cidr                          = "10.1.1.0/24"
  public_subnet_cidrs               = ["10.1.1.0/28"]
  subnet_azs                        = ["us-east-1a"]
  allowed_inbound_cidr_blocks       = ["0.0.0.0/0"] # # TODO: Make sure you change this to your CIDR range, not actual 0.0.0.0/0
  create_iam                        = true
  create_vpc                        = true
}
```

## License

Copyright: &copy; 2019 Kinnaird McQuade


## References

* [Neo4j configuration settings](https://neo4j.com/docs/operations-manual/current/reference/configuration-settings/)

* [Neo4j installation docs](https://neo4j.com/docs/operations-manual/current/installation/)

* [Lyft's Cartography](https://github.com/lyft/cartography)

## TODO
* Better Neo4j config
* Gossamer for AssumeRole across accounts: Support [Gossamer](https://github.com/GESkunkworks/gossamer) on the EC2 instance to store STS credentials from `sts:AssumeRole` commands into accounts that trust your role. Cartography requires that you use an AWS config profile and AWS credentials files. Using Gossamer allows you to fit these requirements.