locals {
  subdirectory_index_count = length(var.default_subdirectory_object) > 0 ? 1 : 0
  subdirectory_index_association = length(var.default_subdirectory_object) > 0 ? [({
    event_type   = "origin-request"
    lambda_arn   = aws_lambda_function.subdirectory_index[0].qualified_arn
    include_body = false
  })] : []
}
data "archive_file" "subdirectory_index" {
  count       = local.subdirectory_index_count
  type        = "zip"
  output_path = "${path.module}/subdirectory-index-lambda.zip"
  source {
    content  = templatefile("${path.module}/subdirectory-index-lambda/index.js.template", { index_file = var.default_subdirectory_object })
    filename = "index.js"
  }
}
resource "aws_lambda_function" "subdirectory_index" {
  count            = local.subdirectory_index_count
  function_name    = "${replace(var.domain_name, ".", "-")}-subdirectory-index"
  description      = "Redirect ${var.domain_name}/subdirectory/ to ${var.domain_name}/subdirectory/index.html"
  filename         = data.archive_file.subdirectory_index[0].output_path
  source_code_hash = filebase64sha256(data.archive_file.subdirectory_index[0].output_path)
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_at_edge.arn
  publish          = true
  lifecycle {
    ignore_changes = [
      filename,
    ]
  }
}
