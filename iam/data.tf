data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}
data "aws_region" "current" {}

data "aws_kms_key" "master" {
  key_id = "alias/${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-master-kmskey"
}
