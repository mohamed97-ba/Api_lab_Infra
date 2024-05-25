output "lambda_arn" {
  value       = module.pipeline.lambda_function_arn
  description = "ARN of Lambda function"
}

output "api_invoke_url" {
  value       = module.api.api_invoke_url
  description = "URL of Api Gateway Stage"
}


