# terraform-aws-ip-address-release

Sometimes AWS fails to release an allocated IP address when tearing down the associated resources. This lambda will release/delete all network interfaces that are in `Status: Available` as they are not associated with a current AWS resource but can't be used by a new AWS resource.

An exception is made for ENIs attached to DataSync tasks since DataSync only establishes ENIs at task creation time.

This includes a 24 hour cloudwatch alarm to trigger the lambda regularly in an effort to keep the account clean and make the resources available for another consumer. 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam"></a> [iam](#module\_iam) | ./iam | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.ip_address_release_lambda_interval](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ip_address_release_lambda_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_function.ip_address_release_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.event_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda_source](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The account name for use in alarm description. | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The ARN of the IAM Role to use (creates a new one if set to `null`) | `string` | `null` | no |
| <a name="input_internet_egress_security_group_id"></a> [internet\_egress\_security\_group\_id](#input\_internet\_egress\_security\_group\_id) | security group id that allows internet outbound calls to port 443 | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the key to give to Lambda for access | `string` | n/a | yes |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Python runtime to use for this lambda | `string` | `"python3.9"` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the policy that is used to set the permissions boundary for the IAM roles. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | prefix name, can be a team or product name. E.g., 'SRE' | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets that Lambda will be created with in the VPC | `list(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout value for the lambda | `number` | `300` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach the IP Address Release lambda to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The IAM Role created, or the one passed in. |
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
* findassociations script in [AWS-support-tools](https://github.com/awslabs/aws-support-tools) can help track down why an ENI is stuck

