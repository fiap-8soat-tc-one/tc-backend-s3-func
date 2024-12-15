resource "aws_lambda_permission" "allow_api_gateway_validate_token" {
  statement_id  = "AllowExecutionFromAPIGatewayValidateToken"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate_token.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_generate_token" {
  statement_id  = "AllowExecutionFromAPIGatewayGenerateToken"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_token.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
