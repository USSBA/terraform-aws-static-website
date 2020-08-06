locals {
  hsts_header_count = length(var.hsts_header) > 0 ? 1 : 0
  hsts_header_association = length(var.hsts_header) > 0 ? [({
        event_type   = "origin-response"
        lambda_arn   = aws_lambda_function.hsts_header[0].qualified_arn
        include_body = false
      })] : []
}
data "archive_file" "hsts_header" {
  count       = local.hsts_header_count
  type        = "zip"
  output_path = "${path.module}/hsts-headers-lambda.zip"
  source {
    content = templatefile("${path.module}/hsts-headers-lambda/index.js.template", { header_value = var.hsts_header })
    filename = "index.js"
  }
}

resource "aws_lambda_function" "hsts_header" {
  count       = local.hsts_header_count
  function_name    = "${replace(var.domain_name, ".","-")}-hsts-headers"
  description      = "Inject HSTS headers into ${var.domain_name} requests"
  filename         = data.archive_file.hsts_header[0].output_path
  source_code_hash = filebase64sha256(data.archive_file.hsts_header[0].output_path)
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_at_edge.arn
  publish          = true
}

