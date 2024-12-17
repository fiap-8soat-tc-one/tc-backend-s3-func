# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "api-gtw-fiap-t32"
  description = "API Gateway"
}

# Aplicação da Resource Policy separadamente
resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/*"
      }
    ]
  })
}

# Root Resource ("/")
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "root_wildcard" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}" # Wildcard que captura qualquer caminho
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

# Método para o recurso "/*" com request_parameters
resource "aws_api_gateway_method" "root_wildcard_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root_wildcard.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Integração da Lambda validate_token com o backend
resource "aws_api_gateway_integration" "root_wildcard_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root_wildcard.id
  http_method             = aws_api_gateway_method.root_wildcard_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${var.backend_url}/{proxy}" # Substituição correta

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}



# Lambda Authorizer para validação de token
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  rest_api_id    = aws_api_gateway_rest_api.api.id
  name           = "TokenValidator"
  type           = "TOKEN"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.validate_token.arn}/invocations"
  identity_source = "method.request.header.X-Authorization-Token"
}

# Deploy do API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.root_wildcard_integration,
    aws_api_gateway_integration.auth_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# Criação do Stage "stg"
resource "aws_api_gateway_stage" "stg" {
  stage_name    = "stg"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  description   = "Stage stg for API Gateway"
}

# Dados da conta AWS
data "aws_caller_identity" "current" {}
