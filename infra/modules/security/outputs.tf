output "lambda_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
  description = "Lambda IAM Role"
}
output "nacloudwatch_role_arnme" {
  value = aws_iam_role.lambda_execution_role.arn
}
