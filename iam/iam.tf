resource "random_string" "random" {
  special = false
  length  = 5
}
resource "aws_iam_role" "lambda_role" {
  name                 = "${var.usecase}-ip-address-release-lambda-role-${random_string.random.result}"
  assume_role_policy   = data.aws_iam_policy_document.lambda_role_trust.json
  description          = "service role for ip address release lambda"
  permissions_boundary = var.permissions_boundary_arn
  tags = {
    Name = "${var.usecase} lambda role"
  }
}

data "aws_iam_policy_document" "lambda_role_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.usecase}-ip-address-release-lambda-policy-${random_string.random.result}"
  description = "lambda policy for ip address release lambda"
  policy      = data.aws_iam_policy_document.lambda_policy_document.json
  tags = {
    Name = "${var.usecase} IP Address Release Lambda Policy"
  }
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    sid    = "lambda"
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "kms"
    effect = "Allow"
    actions = [
      "kms:ListAliases*",
      "kms:CreateGrant",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      data.aws_kms_key.master.arn
    ]
  }
  statement {
    sid    = "VPC"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }
}
