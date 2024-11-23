   provider "aws" {
     region = "eu-central-1"  # Specify your desired region
     profile = "mi4people"
   }

   resource "aws_ecr_repository" "covision_api" {
     name                 = "covision-api2"
     image_tag_mutability = "MUTABLE"  # or "IMMUTABLE"
     image_scanning_configuration {
       scan_on_push = true
     }
   }

   output "repository_url" {
     value = aws_ecr_repository.covision_api.repository_url
   }

   
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}



# lambda function
resource "aws_iam_role" "lambda_exec_role" {
    name = "covision_api_lambda_exec_role"

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

resource "aws_iam_policy_attachment" "lambda_basic_exec" {
    name       = "covision_api_basic_exec"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    roles      = [aws_iam_role.lambda_exec_role.name]
}


resource "aws_lambda_function" "covision_api_lambda" {
    function_name = "CovsionAPILambda"
    role          = aws_iam_role.lambda_exec_role.arn
    package_type  = "Image"
    image_uri     = "181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api:latest"
    architectures = ["arm64"]

    # Optional: Set environment variables
    environment {
    variables = {
        # EXAMPLE_VAR = "example_value"
    }
    }

    # Optional: Memory and timeout settings
    memory_size = 3000
    timeout     = 180
}




resource "aws_apigatewayv2_api" "covision_api_gateway" {
  name          = "CovisionApiGateway"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["x-api-password"]
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.covision_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.covision_api_gateway.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.covision_api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.covision_api_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.covision_api_gateway.id
  route_key = "POST /check-result"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.covision_api_gateway.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id      = aws_apigatewayv2_api.covision_api_gateway.id
  name        = "prod"
  auto_deploy = false
}

resource "aws_apigatewayv2_deployment" "prod_deployment" {
  api_id = aws_apigatewayv2_api.covision_api_gateway.id
  stage_name = aws_apigatewayv2_stage.prod_stage.name
}
   