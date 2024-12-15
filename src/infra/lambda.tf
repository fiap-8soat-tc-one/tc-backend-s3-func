resource "aws_lambda_function" "token-function" {
  filename      = "token.zip"
  function_name = "token-function"
  role          = var.role
  handler       = "main"
  runtime       = "go1.x"

}