data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_source"
  output_path = "${path.module}/ip_address.zip"
}
