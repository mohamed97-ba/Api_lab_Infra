
resource "aws_lambda_function" "lambda" {
  filename      = "lambda_function.zip"
  function_name = "client_data_handler"
  role          = var.lambda_role_arn
  handler       = "lambda.lambda_handler"

  source_code_hash = filebase64sha256("lambda_function.zip")

  runtime = "python3.9"

  environment {
    variables = {
      BUCKET_NAME = "${var.bucket_name}"
    }
  }
}

