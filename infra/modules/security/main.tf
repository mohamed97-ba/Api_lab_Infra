resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_bucket_policy" {
  name = "lambda_bucket_policy"
  policy = data.aws_iam_policy_document.bucket_policy.json

}
resource "aws_iam_policy_attachment" "lambda_bucket_policy_attachement" {
  name = "lambda_bucket_policy_attachement"
  roles = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.lambda_bucket_policy.arn
}
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = true
}