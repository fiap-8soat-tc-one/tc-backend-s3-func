
# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "api-gtw-fiap-t32"
  description = "API Gateway"
}

# Root Resource ("/")
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}

# Método para /auth (executa generate_token)
resource "aws_api_gateway_method" "auth_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integração da Lambda generate_token com /auth
resource "aws_api_gateway_integration" "auth_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth.id
  http_method             = aws_api_gateway_method.auth_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.generate_token.arn}/invocations"
}

# Método para /api (executa validate_token e redireciona ao backend)
resource "aws_api_gateway_method" "api_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
}

# Integração da Lambda validate_token com o backend
resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api_get.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = var.backend_url
}

# Lambda Authorizer para validação de token
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  rest_api_id    = aws_api_gateway_rest_api.api.id
  name           = "TokenValidator"
  type           = "TOKEN"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.validate_token.arn}/invocations"
}

# Deploy do API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.api_integration,
    aws_api_gateway_integration.auth_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
}