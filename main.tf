module "iam" {
  source = "./iam"

  count                    = var.iam_role_arn == null ? 1 : 0
  prefix                   = var.prefix
  account_name             = var.account_name
  permissions_boundary_arn = var.permissions_boundary_arn
  kms_key_arn              = var.kms_key_arn
}
