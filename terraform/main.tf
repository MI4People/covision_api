   provider "aws" {
     region = "eu-central-1"  # Specify your desired region
     profile = "mi4people"
   }

   # resource "aws_ecr_repository" "covision_api_tf" {
   #   name                 = "covision-api2"
   #   image_tag_mutability = "MUTABLE"  # or "IMMUTABLE"
   #   image_scanning_configuration {
   #     scan_on_push = true
   #   }
   # }

   # output "repository_url" {
   #   value = aws_ecr_repository.covision_api_tf.repository_url
   # }

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Systems Manager Parameter 
resource "aws_ssm_parameter" "covision_api_secret_tf" {
  name  = "CoVisionAPISecretTF"
  type  = "SecureString"
  #todo update this to random value
  value = "your-secret-value"  # Replace with actual secret value
}

output "covision_api_secret_arn" {
  value = aws_ssm_parameter.covision_api_secret_tf.arn
}

# lambda function role
resource "aws_iam_role" "lambda_exec_role_tf" {
    name = "covision_api_lambda_exec_role_tf"

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
}

resource "aws_iam_policy" "lambda_ssm_policy_tf" {
  name = "covision_api_lambda_ssm_policy_tf"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ssm:GetParameter"
        Resource = aws_ssm_parameter.covision_api_secret_tf.arn
      },
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = "arn:aws:kms:eu-central-1:123456789012:key/a5cc7cca-90e1-4a65-9aa6-ff5dc93bd5d6"
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "lambda_basic_exec_tf" {
    name       = "covision_api_basic_exec_tf"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    roles      = [aws_iam_role.lambda_exec_role_tf.name]
}

resource "aws_iam_policy_attachment" "lambda_ssm_exec_tf" {
    name       = "covision_api_ssm_exec_tf"
    policy_arn = aws_iam_policy.lambda_ssm_policy_tf.arn
    roles      = [aws_iam_role.lambda_exec_role_tf.name]
}

# Lambda function
resource "aws_lambda_function" "covision_api_lambda_tf" {
    function_name = "CovsionAPILambda_TF"
    role          = aws_iam_role.lambda_exec_role_tf.arn
    package_type  = "Image"
    # image_uri     = "181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api:v2"
    image_uri     = "181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api:v3"
    architectures = ["arm64"]

    # Optional: Set environment variables
    environment {
      variables = {
        API_PASSWORD_NAME = aws_ssm_parameter.covision_api_secret_tf.name
      }
    }

    # Optional: Memory and timeout settings
    memory_size = 3000
    ephemeral_storage {
        size = 1000
    }
    timeout     = 180
}

# API Gateway
resource "aws_apigatewayv2_api" "covision_api_gateway_tf" {
  name          = "CovisionApiGateway_TF"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["x-api-password"]
  }
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
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.covision_api_lambda_tf.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route_tf" {
  api_id    = aws_apigatewayv2_api.covision_api_gateway_tf.id
  route_key = "POST /check-result"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_tf.id}"
}

resource "aws_apigatewayv2_stage" "default_stage_tf" {
  api_id      = aws_apigatewayv2_api.covision_api_gateway_tf.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "prod_stage_tf" {
  api_id      = aws_apigatewayv2_api.covision_api_gateway_tf.id
  name        = "prod"
  auto_deploy = false
}
