# This file contains the Cloudwatch alarms that attach to the timer service alarm lambda.
resource "aws_cloudwatch_event_rule" "ip_address_release_lambda_interval" {
  name                = "${var.usecase}-ip-address-lambda-release-rule"
  description         = "Fires every 24 hours"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "ip_address_release_lambda_attach" {
  rule = aws_cloudwatch_event_rule.ip_address_release_lambda_interval.name
  arn  = aws_lambda_function.ip_address_release_lambda.arn
}

resource "aws_lambda_permission" "event_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ip_address_release_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ip_address_release_lambda_interval.arn
}
