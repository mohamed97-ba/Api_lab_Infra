

module "security" {
  source      = "../../modules/security"
  bucket_name = var.bucket_name
  
}

module "pipeline" {
  source          = "../../modules/pipeline"
  lambda_role_arn = module.security.lambda_role_arn
  bucket_name     = var.bucket_name

  depends_on = [module.security]
}


module "api" {
  source                     = "../../modules/api"
  lambda_function_invoke_arn = module.pipeline.lambda_function_invoke_arn
  lambda_function_name       = module.pipeline.lambda_function_name
  cloudwatch_role_arn = module.security.lambda_role_arn
}


