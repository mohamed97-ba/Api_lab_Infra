data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ 
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com"
         ]
    }
    actions = [ "sts:AssumeRole" ]

  }
}

data "aws_iam_policy_document" "bucket_policy" {

  statement {
    effect   = "Allow"
    actions   = [
            "s3:PutObject",
          ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      ]
        }
  statement {
    effect   = "Allow"
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]
    resources = [
      "*",
      ]
        }
  }
  