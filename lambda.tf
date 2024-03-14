resource "aws_lambda_function" "ip_address_release_lambda" {
  filename         = data.archive_file.lambda_source.output_path
  function_name    = "${var.prefix}-ip-address-release-lambda"
  role             = var.iam_role_arn == null ? module.iam[0].role_arn : var.iam_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)
  runtime          = var.lambda_runtime
  architectures    = ["arm64"]
  timeout          = var.timeout

  environment {
    variables = {
      prefix = var.prefix
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [
      var.internet_egress_security_group_id
    ]
  }
}

