resource "aws_eip" "nat" {
  count = $eip_count
  vpc = true
  tags = {
$tags
  }
}


output "ids" {
  description = "Resource ids"
  value       = "${D}{aws_eip.nat.*.id}"
}

output "ips" {
  description = "Reserved IPs"
  value       = "${D}{aws_eip.nat.*.public_ip}"
}

#if (! $instance.getParentInstanceByPacketType("TERRAFORM-AWS-RUNNER"))
provider "aws" {
  region = "us-east-1"
  version = "~> 2.32.0"
}

#end