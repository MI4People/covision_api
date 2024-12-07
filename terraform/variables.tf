variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "tag_project_name" {
  description = "The project name for tagging resources"
  type        = string
}

variable "tag_organization_name" {
  description = "The organization name for tagging resources"
  type        = string
}

variable "kms_key_tag_name" {
  description = "The value for the 'Name' tag of the KMS key"
  type        = string
}

variable "ssm_parameter_name" {
  description = "The SSM parameter name"
  type        = string
}

variable "ssm_parameter_type" {
  description = "The SSM parameter type"
  type        = string
}

variable "ssm_parameter_value" {
  description = "The SSM parameter value"
  type        = string
  sensitive   = true
}

variable "iam_role_name" {
  description = "The name of IAM role for lambda function"
  type        = string
}

variable "iam_ssm_policy_name" {
  description = "The name of IAM policy for lambda function to access SSM parameter"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the lambda function"
  type        = string
}

variable "lambda_package_type" {
  description = "The type of the lambda function package"
  type        = string
}

variable "lambda_image_uri" {
  description = "The URI of the lambda function image"
  type        = string
}

variable "lambda_image_architecture" {
  description = "The architecture of the lambda function image"
  type        = string
}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_gateway_type" {
  description = "The type of the API Gateway"
  type        = string
}

variable "api_gateway_allow_headers" {
  description = "The headers allowed in the API Gateway"
  type        = list(string)
}

variable "api_gateway_integration_type" {
  description = "The integration type of the API Gateway"
  type        = string
}

variable "api_gateway_route_key" {
  description = "The route key of the API Gateway"
  type        = string
}