module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 5.2.1"

  name          = var.environment
  description   = "API Gateway for ${var.environment} environment"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_certificate = false
  create_domain_name = false

  domain_name_certificate_arn = aws_acm_certificate.this.arn

  disable_execute_api_endpoint = false

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 3
  }

  stage_default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 50
    throttling_rate_limit    = 50
  }

  authorizers = {
    lambda = {
      authorizer_payload_format_version = "2.0"
      authorizer_type                   = "REQUEST"
      authorizer_uri                    = module.lambda_authorizer.lambda_function_invoke_arn
      enable_simple_responses           = true
      identity_sources                  = ["$request.header.x-api-key"]
      name                              = "APIKeyAuthorizer"
    }
  }

  routes = {
    "POST /get" = {
      authorization_type = "CUSTOM"
      authorizer_key     = "lambda"
      integration = {
        method                 = "POST"
        uri                    = module.lambda_get.lambda_function_arn
        payload_format_version = "1.0"
      }
    }
    "POST /post" = {
      authorization_type = "CUSTOM"
      authorizer_key     = "lambda"
      integration = {
        method                 = "POST"
        uri                    = module.lambda_post.lambda_function_arn
        payload_format_version = "1.0"
      }
    }
    "$default" = {
      authorization_type = "CUSTOM"
      authorizer_key     = "lambda"
      integration = {
        method                 = "ANY"
        uri                    = module.lambda_get.lambda_function_arn
        payload_format_version = "1.0"
      }
    }
  }

  tags = var.tags
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id      = module.api_gateway.api_id
  domain_name = aws_apigatewayv2_domain_name.this.id
  stage       = module.api_gateway.stage_id
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = local.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.this.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${var.environment}"

  retention_in_days = 3
}
