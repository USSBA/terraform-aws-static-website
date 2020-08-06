resource "aws_iam_role" "lambda_at_edge" {
  name_prefix = var.name_prefix
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

data "aws_iam_policy_document" "lambda_at_edge" {
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_at_edge" {
  name_prefix = var.name_prefix
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_at_edge.json
}

resource "aws_iam_role_policy_attachment" "lambda_at_edge" {
  role       = aws_iam_role.lambda_at_edge.name
  policy_arn = aws_iam_policy.lambda_at_edge.arn
}
