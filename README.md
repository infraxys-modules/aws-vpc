# AWS VPC Infraxys module


## Introduction

This module contains packets, roles and code to provision AWS VPCs. Provisioning is done using Terraform.

See the [Quick start guide](QUICK-START-GUIDE.md).

## Packets

### AWS EIP

[See AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-ip-addresses-eip.html)

### AWS Network ACL

[See AWS documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)

### AWS Network ACL Rule

[See AWS documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-rules)

### AWS VPC - private shared and public subnets

[See AWS documentation](https://aws.amazon.com/vpc/)

### AWS VPC variables

This packet contains several attributes that are used from roles like "VPC with private, shared and public subnet".

## Roles

### VPC with private, shared and public subnet

This role contains the full definition of a VPC with the specified subnets.

#### Requirements

An instance of packet "AWS Core variables" and another of "AWS VPC variables" have to exist on containers that inherit this role.
These instances are created automatically when the role is dropped on a container.
You could create a separate role with these variables so this configuration can be shared between environments.

