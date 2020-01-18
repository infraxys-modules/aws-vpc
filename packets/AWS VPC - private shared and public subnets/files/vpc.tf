#set ($azList = $velocityService.getNewList())
#set ($currentSuffix = "a")
#foreach($i in [1..$Integer.parseInt($az_count)])
#set ($dummy = $azList.add("${aws_region}$currentSuffix"))
#set ($currentSuffix = $velocityUtils.nextAlphabeticCharacter($currentSuffix))
#end
#set ($azs = '"' + $String.join('","', $azList) + '"')

provider "aws" {
  region = "$aws_region"
  version = "~> 2.32.0"
}

data "terraform_remote_state" "aws_eip" {
  backend = "s3"
  config = {
    bucket = "$aws_core_s3_state_bucket"
    key = "$aws_core_s3_state_folder/nat-eip.tfstate"
    region = "$aws_core_region"
  }
}

module "vpc" {
#  source              = "github.com/infraxys-modules/terraform-aws-vpc?ref=master"
source              = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=master"
  name                = "${vpc_name}"
  vpc_tags = {
    $vpc_tag_list.replaceAll("<suffix>", "-vpc")
  }
  cidr                = "$vpc_cidr"
  azs                 = [ $azs ]
  private_subnet_tags = {
    $vpc_tag_list.replaceAll("<suffix>", "-private-sn")
  }
  public_subnet_tags = {
    $vpc_tag_list.replaceAll("<suffix>", "-public-sn")
  }
  database_subnet_tags = {
    $vpc_tag_list.replaceAll("<suffix>", "-database-sn")
  }

  public_subnet_suffix = "public"
  private_subnet_suffix = "private"
  database_subnet_suffix = "database"

  #if ($az_count == 1)
  private_subnets     = [ "${D}{cidrsubnet("$vpc_cidr",4,0)}" ]
  public_subnets      = [ "${D}{cidrsubnet("$vpc_cidr",4,1)}" ]
  database_subnets    = [ "${D}{cidrsubnet("$vpc_cidr",4,2)}" ]
  #elseif ($az_count == 2)
  private_subnets     = [ "${D}{cidrsubnet("$vpc_cidr",4,0)}", "${D}{cidrsubnet("$vpc_cidr",4,1)}" ]
  public_subnets      = [ "${D}{cidrsubnet("$vpc_cidr",4,2)}", "${D}{cidrsubnet("$vpc_cidr",4,3)}" ]
  database_subnets    = [ "${D}{cidrsubnet("$vpc_cidr",4,4)}", "${D}{cidrsubnet("$vpc_cidr",4,5)}" ]
  #elseif ($az_count == 3)
  private_subnets     = [ "${D}{cidrsubnet("$vpc_cidr",4,0)}", "${D}{cidrsubnet("$vpc_cidr",4,1)}", "${D}{cidrsubnet("$vpc_cidr",4,2)}" ]
  public_subnets      = [ "${D}{cidrsubnet("$vpc_cidr",4,3)}", "${D}{cidrsubnet("$vpc_cidr",4,4)}", "${D}{cidrsubnet("$vpc_cidr",4,5)}" ]
  database_subnets    = [ "${D}{cidrsubnet("$vpc_cidr",4,6)}", "${D}{cidrsubnet("$vpc_cidr",4,7)}", "${D}{cidrsubnet("$vpc_cidr",4,8)}" ]
  #else
  $environment.throwException("Number of availability zones should be 1, 2 or 3.")
#end
#if ($nat_scenario == "NAT_PER_SUBNET")
enable_nat_gateway = true
single_nat_gateway = false
one_nat_gateway_per_az = false
#elseif ($nat_scenario == "SINGLE_NAT")
enable_nat_gateway = true
single_nat_gateway = true
one_nat_gateway_per_az = false
#else
enable_nat_gateway = true
single_nat_gateway = false
one_nat_gateway_per_az = true
#end

reuse_nat_ips       = true
external_nat_ip_ids = data.terraform_remote_state.aws_eip.outputs.ids
## #if ( $az_count == 1)
##external_nat_ip_ids = ["${D}{data.terraform_remote_state.aws_eip.ids}"]
## #else
## external_nat_ip_ids = "${D}{data.terraform_remote_state.aws_eip.*.ids}"
## #end

create_database_subnet_group = false

enable_dns_hostnames = true
enable_dns_support   = true

enable_vpn_gateway = false

enable_dhcp_options              = false
#dhcp_options_domain_name         = "service.consul"
#dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

# VPC endpoint for S3
enable_s3_endpoint = true

# VPC endpoint for DynamoDB
enable_dynamodb_endpoint = true

# VPC endpoint for SSM
enable_ssm_endpoint              = false
#ssm_endpoint_private_dns_enabled = true
#ssm_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"] # ssm_endpoint_subnet_ids = ["..."]

# VPC endpoint for SSMMESSAGES
enable_ssmmessages_endpoint              = false
#ssmmessages_endpoint_private_dns_enabled = true
#ssmmessages_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"]

# VPC Endpoint for EC2
enable_ec2_endpoint              = false
#ec2_endpoint_private_dns_enabled = true
#ec2_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"]

# VPC Endpoint for EC2MESSAGES
enable_ec2messages_endpoint              = false
#ec2messages_endpoint_private_dns_enabled = true
#ec2messages_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"]

# VPC Endpoint for ECR API
enable_ecr_api_endpoint              = false
#ecr_api_endpoint_private_dns_enabled = true
#ecr_api_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"]

# VPC Endpoint for ECR DKR
enable_ecr_dkr_endpoint              = false
#ecr_dkr_endpoint_private_dns_enabled = true
#ecr_dkr_endpoint_security_group_ids  = ["${D}{data.aws_security_group.default.id}"]

}
