module "lambda_aggregate" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.17.0"

  function_name = "${var.environment}_aggregate"
  description   = "Function to update aggregates in DynamoDB"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.13"
  timeout       = 60

  environment_variables = {
    AGGREGATES_TABLE = aws_dynamodb_table.aggregates.id
  }

  source_path = [
    {
      path             = "${path.module}/lambda_aggregate"
      pip_requirements = false
    }
  ]

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
      ],
      resources = [aws_dynamodb_table.aggregates.arn]
    }
  }

  allowed_triggers = {
    AllowExecutionFromDynamoDBStream = {
      service    = "dynamodb"
      source_arn = aws_dynamodb_table.raw_data.stream_arn
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}

module "lambda_authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.17.0"

  function_name = "${var.environment}_authorizer"
  description   = "${replace(var.environment, "_", " ")} api authorizer function"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.13"
  timeout       = 30

  environment_variables = {
    API_KEY_SECRET = aws_secretsmanager_secret.api_key.name
  }

  source_path = [
    {
      path             = "${path.module}/lambda_authorizer"
      pip_requirements = false
    }
  ]

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    secrets = {
      effect    = "Allow",
      actions   = ["secretsmanager:*"],
      resources = [aws_secretsmanager_secret.api_key.arn]
    }
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}

module "lambda_get" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.17.0"

  function_name = "${var.environment}_get"
  description   = "${replace(var.environment, "_", " ")} function to get information from DynamoDB"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.13"
  timeout       = 30

  environment_variables = {
    AGGREGATES_TABLE = aws_dynamodb_table.aggregates.id
  }

  source_path = [
    {
      path             = "${path.module}/lambda_get"
      pip_requirements = false
    }
  ]

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:Query"],
      resources = [aws_dynamodb_table.aggregates.arn]
    }
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}

module "lambda_post" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.17.0"

  function_name = "${var.environment}_post"
  description   = "${replace(var.environment, "_", " ")} function to put records in DynamoDB"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.13"
  timeout       = 300

  environment_variables = {
    AGGREGATES_TABLE = aws_dynamodb_table.aggregates.id
    RAW_DATA_TABLE   = aws_dynamodb_table.raw_data.id
  }

  source_path = [
    {
      path             = "${path.module}/lambda_post"
      pip_requirements = false
    }
  ]

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
      ],
      resources = [
        aws_dynamodb_table.aggregates.arn,
        aws_dynamodb_table.raw_data.arn
      ]
    }
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}

resource "aws_secretsmanager_secret" "api_key" {
  name        = "${var.environment}_api_key"
  description = "${replace(var.environment, "_", " ")} API key"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id = aws_secretsmanager_secret.api_key.id

  secret_string = jsonencode({ "API_KEY" : "" })

  lifecycle {
    ignore_changes = [secret_string]
  }
}