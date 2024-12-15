resource "aws_lambda_function" "validate_token" {
  function_name = "validate_token"
  runtime       = "provided.al2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"

  filename = "../funcs/validate_token/validate_token.zip"

  environment {
    variables = {
      BACKEND_URL = var.backend_url
    }
  }
}

resource "aws_lambda_function" "generate_token" {
  function_name = "generate_token"
  runtime       = "provided.al2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"

  filename = "../funcs/generate_token/generate_token.zip"

  environment {
    variables = {
      BACKEND_URL = var.backend_url
    }
  }
}