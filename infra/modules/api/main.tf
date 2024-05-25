
resource "aws_api_gateway_rest_api" "api" {
  name = "ClientDataAPI"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  binary_media_types = ["multipart/form-data"]
  description = "API to handle client data uploads"
}
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id =  aws_api_gateway_rest_api.api.root_resource_id
  path_part = "upload"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "POST"
  authorization = "NONE"
  request_models = {
    "multipart/form-data" = "Empty"
  }
  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
  request_templates = {
    "multipart/form-data" = <<EOF
{
  "body": "$util.base64Encode($input.body)",
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))"
    #if($foreach.hasNext),#end
    #end
  },
  "queryStringParameters": {
    #foreach($queryParam in $input.params().querystring.keySet())
    "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))"
    #if($foreach.hasNext),#end
    #end
  },
  "pathParameters": {
    #foreach($pathParam in $input.params().path.keySet())
    "$pathParam": "$util.escapeJavaScript($input.params().path.get($pathParam))"
    #if($foreach.hasNext),#end
    #end
  }
}
EOF
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.lambda_integration
  ]
}
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}

