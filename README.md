# terraform-aws-ip-address-release

Sometimes AWS fails to release an allocated IP address when tearing down the associated resources. This lambda will release/delete all network interfaces that are in `Status: Available` as they are not associated with a current AWS resource but can't be used by a new AWS resource.

An exception is made for ENIs attached to DataSync tasks since DataSync only establishes ENIs at task creation time.

This includes a 24 hour cloudwatch alarm to trigger the lambda regularly in an effort to keep the account clean and make the resources available for another consumer.

<!-- BEGIN_TF_DOCS -->


<!-- END_TF_DOCS -->

# Multi-region deployment
The IAM role created for the initial region can be reused for the second region by referencing the outputs from the first region.
```terraform
* assumes a non-aliased provider is setup elsewhere
module "ip-address-release-primary" {
  source = "git::https://github.com/StateFarmIns/terraform-aws-ip-address-release?ref=1.0.0" 

  providers = {
    aws = aws
  }

  prefix                           = "SRE"
  account_name                      = var.account_name
  permissions_boundary_arn          = local.permissions_boundary
  internet_egress_security_group_id = data.aws_security_group.https-internet-egress_primary.id
  vpc_id                            = data.aws_vpc.internal_primary.id
  subnet_ids                        = data.aws_subnets.private_subnets_primary.ids
  kms_key_arn                       = data.aws_kms_key.master_primary.arn

}

* assumes an aliased (secondary) provider is setup elsewhere
module "ip-address-release-secondary" {
  source = "git::https://github.com/StateFarmIns/terraform-aws-ip-address-release?ref=1.0.0" 

  providers = {
    aws = aws.secondary
  }

  prefix                           = "SRE"
  account_name                      = var.account_name
  permissions_boundary_arn          = local.permissions_boundary
  internet_egress_security_group_id = data.aws_security_group.https-internet-egress_secondary.id
  iam_role_arn                      = module.ip-address-release-primary.iam_role_arn # reference the IAM Role created earlier
  vpc_id                            = data.aws_vpc.internal_secondary.id
  subnet_ids                        = data.aws_subnets.private_subnets_secondary.ids
  kms_key_arn                       = data.aws_kms_key.master_secondary.arn
}
```

# Links
* [Why can't I detach or delete an elastic network interface that Lambda created?](https://aws.amazon.com/premiumsupport/knowledge-center/lambda-eni-find-delete/)
* [Requester Managed Network Interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requester-managed-eni.html)
* findassociations script copied from [AWS-support-tools](https://github.com/awslabs/aws-support-tools)

