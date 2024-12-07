resource "aws_api_gateway_rest_api" "api-gw-authorization" {
  name        = "api-gw-authorization"
  description = "API Gateway Invoke Lambda"
}