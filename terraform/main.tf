   provider "aws" {
     region = var.region  # Specify your desired region
     profile = "mi4people" # this is profile for aws, if not needed or configured, remove this line
   }

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  common_tags = {
    project      = var.tag_project_name
    organization = var.tag_organization_name
  }
}

# KMS key to encrypt and decrypt SSM Parameter
resource "aws_kms_key" "covision_kms_key" {
  description             = "KMS key for encrypting and decrypting CoVision API SSM Parameter secrets"
  deletion_window_in_days = 30

  # Optional: Define key usage and key spec
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  # Add tags to the KMS key
  tags = {
    Name        = var.kms_key_tag_name
    project     = var.tag_project_name
    organization = var.tag_organization_name
  }
}

# Systems Manager Parameter 
resource "aws_ssm_parameter" "covision_api_secret_tf" {
  name  = var.ssm_parameter_name
  type  = var.ssm_parameter_type
  value = var.ssm_parameter_value
  tags = local.common_tags
}

# lambda function role
resource "aws_iam_role" "lambda_exec_role_tf" {
    name = var.iam_role_name

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
        }
    ]
    })

    tags = local.common_tags
}

resource "aws_iam_policy" "lambda_ssm_policy_tf" {
  name = var.iam_ssm_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ssm:GetParameter"
        Resource = aws_ssm_parameter.covision_api_secret_tf.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "lambda_kms_policy_tf" {
  name = "covision_api_lambda_kms_policy_tf"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = aws_kms_key.covision_kms_key.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy_attachment" "lambda_basic_exec_tf" {
    name       = "covision_api_lambda_basic_exec_tf"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    roles      = [aws_iam_role.lambda_exec_role_tf.name]
}

resource "aws_iam_policy_attachment" "lambda_ssm_exec_tf" {
    name       = "covision_api_lambda_ssm_exec_tf"
    policy_arn = aws_iam_policy.lambda_ssm_policy_tf.arn
    roles      = [aws_iam_role.lambda_exec_role_tf.name]
}

resource "aws_iam_policy_attachment" "lambda_kms_exec_tf" {
    name       = "covision_api_lambda_kms_exec_tf"
    policy_arn = aws_iam_policy.lambda_kms_policy_tf.arn
    roles      = [aws_iam_role.lambda_exec_role_tf.name]
}

# Lambda function
resource "aws_lambda_function" "covision_api_lambda_tf" {
    function_name = var.lambda_function_name
    role          = aws_iam_role.lambda_exec_role_tf.arn
    package_type  = var.lambda_package_type
    image_uri     = var.lambda_image_uri
    architectures = [var.lambda_image_architecture]

    # Optional: Set environment variables
    environment {
      variables = {
        API_PASSWORD_NAME = aws_ssm_parameter.covision_api_secret_tf.name
      }
    }

    # Optional:  mininum Memory and timeout settings
    memory_size = 3000
    ephemeral_storage {
        size = 1000
    }
    timeout     = 180

    # Add tags to the Lambda function
    tags = local.common_tags
}

# API Gateway
resource "aws_apigatewayv2_api" "covision_api_gateway_tf" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_type
  cors_configuration {
    allow_headers = var.api_gateway_allow_headers
  }
  tags = local.common_tags
}

resource "aws_lambda_permission" "apigw_lambda_tf" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.covision_api_lambda_tf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.covision_api_gateway_tf.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration_tf" {
  api_id           = aws_apigatewayv2_api.covision_api_gateway_tf.id
  integration_type = var.api_gateway_integration_type
  integration_uri  = aws_lambda_function.covision_api_lambda_tf.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route_tf" {
  api_id    = aws_apigatewayv2_api.covision_api_gateway_tf.id
  route_key =  var.api_gateway_route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_tf.id}"
}

resource "aws_apigatewayv2_stage" "default_stage_tf" {
  api_id      = aws_apigatewayv2_api.covision_api_gateway_tf.id
  name        = "$default"
  auto_deploy = true
}


