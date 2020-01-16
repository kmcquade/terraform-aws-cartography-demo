# terraform-aws-cartography-demo

This module creates the infrastructure for Lyft's [Cartography](https://github.com/lyft/cartography#installation) in AWS.

## Disclaimer

This is meant to be a starting point / POC for anyone testing out Cartography. I made this for my own purposes. It is NOT meant for use in a production environment.

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

* It will bring you to the Neo4j database login. Enter `bolt` as your username and password.

### Query for privileged public instances

```text
MATCH (n:EC2Instance) 
WHERE  (n.iaminstanceprofile) starts with 'arn' and (n.publicdnsname) contains '.'
RETURN n.region, n.instanceid, n.iaminstanceprofile, n.publicdnsname
```


###
```text
match (lb:LoadBalancer{scheme:"internet-facing"})-[:MEMBER_OF_EC2_SECURITY_GROUP]->(sb:EC2SecurityGroup)<-[:MEMBER_OF_EC2_SECURITY_GROUP]-(IP:IpPermissionInbound{protocol:"tcp"})<-[:MEMBER_OF_IP_RULE]-(rule:IpRange{range:"0.0.0.0/0"}) return lb, sb,IP,rule
```

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

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_inbound\_cidr\_blocks | Allowed inbound CIDRs for the security group rules. | `list(string)` | `[]` | no |
| attributes | Additional attributes, e.g. `1` | `list(string)` | `[]` | no |
| cartography\_config\_rendered | The ~/.aws/config file for cartography user. Use this for gathering data from multiple accounts. If no value is set, it will just set the default config. | `string` | `""` | no |
| cartography\_instance\_profile\_name | If create\_iam is set to false, use this instance profile name for Cartography server instead. | `any` | n/a | yes |
| convert\_case | Convert fields to lower case | `string` | `"true"` | no |
| create\_bucket | Set to false to disable creation of an S3 bucket for cartography config | `bool` | `true` | no |
| create\_iam | Set to false to disable creation of IAM resources. Default value is true. | `bool` | `true` | no |
| create\_vpc | Set to false to disable creation of VPC resources. Default value is true. | `bool` | `true` | no |
| default\_tags | Default billing tags to be applied across all resources | `map(string)` | `{}` | no |
| delimiter | Delimiter to be used between (1) `namespace`, (2) `name`, (3) `stage` and (4) `attributes` | `string` | `"-"` | no |
| ec2\_ami\_name\_filter | The name of the AMI to search for. Defaults to amzn2-ami-hvm-2.0.2019\*-x86\_64-ebs | `string` | `"amzn2-ami-hvm-2.0.2019*-x86_64-ebs"` | no |
| ec2\_ami\_owner\_filter | List of AMI owners to limit search. Defaults to `amazon`. | `string` | `"amazon"` | no |
| enable\_bucket\_versioning | Set to true to enable bucket versioning | `bool` | `false` | no |
| force\_destroy | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `true` | no |
| key\_name | The name of the SSH key in AWS to use for accessing the EC2 instance. | `any` | n/a | yes |
| kms\_key\_alias | The KMS key alias to use for the EBS Volume | `string` | `"alias/cartography"` | no |
| name | Name, which could be the name of your solution or app. Third item in naming sequence. | `any` | n/a | yes |
| namespace | Namespace, which could be your organization name. First item in naming sequence. | `any` | n/a | yes |
| public\_subnet\_cidrs | The CIDR block of the public subnet. | `list(string)` | <code><pre>[<br>  "10.1.1.0/28"<br>]<br></pre></code> | no |
| region | The AWS region for these resources, such as us-east-1. | `any` | n/a | yes |
| stage | Stage, e.g. `prod`, `staging`, `dev`, or `test`. Second item in naming sequence. | `any` | n/a | yes |
| subnet\_azs | Subnets will be created in these availability zones. | `list(string)` | <code><pre>[<br>  "us-east-1a"<br>]<br></pre></code> | no |
| vpc\_cidr | The CIDR block for the VPC. | `string` | `"10.1.1.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | The public IP address of the EC2 instance running Cartography. |
| zREADME | n/a |

## References

* [Neo4j configuration settings](https://neo4j.com/docs/operations-manual/current/reference/configuration-settings/)

* [Neo4j installation docs](https://neo4j.com/docs/operations-manual/current/installation/)

* [Lyft's Cartography](https://github.com/lyft/cartography)

## TODO
* Better Neo4j config
