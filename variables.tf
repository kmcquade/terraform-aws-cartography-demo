# ---------------------------------------------------------------------------------------------------------------------
# GENERAL
# These variables pass in general data from the calling module, such as the AWS Region and billing tags.
# ---------------------------------------------------------------------------------------------------------------------

variable "default_tags" {
  description = "Default billing tags to be applied across all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The AWS region for these resources, such as us-east-1."
}

# ---------------------------------------------------------------------------------------------------------------------
# TOGGLES
# Toogle to true to create resources
# ---------------------------------------------------------------------------------------------------------------------

variable "create_iam" {
  description = "Set to false to disable creation of IAM resources. Default value is true."
  default     = true
}

variable "create_vpc" {
  description = "Set to false to disable creation of VPC resources. Default value is true."
  default     = true
}


variable "create_bucket" {
  description = "Set to false to disable creation of an S3 bucket for cartography config"
  default     = true
}

variable "enable_bucket_versioning" {
  description = "Set to true to enable bucket versioning"
  default     = false
}


# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE VALUES
# These variables pass in actual values to configure resources. CIDRs, Instance Sizes, etc.
# ---------------------------------------------------------------------------------------------------------------------
variable "cartography_instance_profile_name" {
  description = "If create_iam is set to false, use this instance profile name for Cartography server instead."
}

variable "key_name" {
  description = "The name of the SSH key in AWS to use for accessing the EC2 instance."
}

variable "instance_type" {
  description = "The size of the Ec2 instance. Defaults to t2.medium"
  default     = "t2.medium"
}

variable "volume_size" {
  description = "The disk size for the EC2 instance root volume. Defaults to 50 (for 50GB)"
  default     = 50
}

variable "kms_key_alias" {
  description = "The KMS key alias to use for the EBS Volume"
  default     = "alias/cartography"
}

##### Networking
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.1.1.0/24"

}
variable "subnet_azs" {
  description = "Subnets will be created in these availability zones."
  type        = list(string)
  default     = ["us-east-1a"]

}

variable "public_subnet_cidrs" {
  description = "The CIDR block of the public subnet."
  type        = list(string)
  default     = ["10.1.1.0/28"]
}

variable "allowed_inbound_cidr_blocks" {
  description = "Allowed inbound CIDRs for the security group rules."
  default     = []
  type        = list(string)
}

# S3 bucket
variable "force_destroy" {
  description = "A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = true
}


# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE REFERENCES
# These variables pass in metadata on other AWS resources, such as ARNs, Names, etc.
# ---------------------------------------------------------------------------------------------------------------------
variable "ec2_ami_owner_filter" {
  description = "List of AMI owners to limit search. Defaults to `amazon`."
  default     = "amazon"
  type        = string
}

variable "ec2_ami_name_filter" {
  description = "The name of the AMI to search for. Defaults to amzn2-ami-hvm-2.0.2019*-x86_64-ebs"
  default     = "amzn2-ami-hvm-2.0.2019*-x86_64-ebs"
  type        = string
}

variable "cartography_config_rendered" {
  description = "The ~/.aws/config file for cartography user. Use this for gathering data from multiple accounts. If no value is set, it will just set the default config."
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# NAMING
# This manages the names of resources in this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "namespace" {
  description = "Namespace, which could be your organization name. First item in naming sequence."
}

variable "stage" {
  description = "Stage, e.g. `prod`, `staging`, `dev`, or `test`. Second item in naming sequence."
}

variable "name" {
  description = "Name, which could be the name of your solution or app. Third item in naming sequence."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes, e.g. `1`"
}

variable "convert_case" {
  description = "Convert fields to lower case"
  default     = "true"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between (1) `namespace`, (2) `name`, (3) `stage` and (4) `attributes`"
}