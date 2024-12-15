resource "aws_api_gateway_resource" "api-gw-authorization" {
  rest_api_id = aws_api_gateway_rest_api.api-gw-authorization.id
  parent_id   = aws_api_gateway_rest_api.api-gw-authorization.root_resource_id
  path_part   = "meu-recurso"
}

resource "aws_api_gateway_method" "api-gw-authorization" {
  rest_api_id   = aws_api_gateway_rest_api.api-gw-authorization.id
  resource_id   = aws_api_gateway_resource.api-gw-authorization.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api-gw-authorization" {
  rest_api_id             = aws_api_gateway_rest_api.api-gw-authorization.id
  resource_id             = aws_api_gateway_resource.api-gw-authorization.id
  http_method             = aws_api_gateway_method.api-gw-authorization.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.token-function.invoke_arn
}

