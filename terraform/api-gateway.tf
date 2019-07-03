resource "aws_api_gateway_rest_api" "java_lambda_api" {
  name        = "java_lambda_api"
  description = "Java Lambda on Terrraform"
}

resource "aws_api_gateway_resource" "java_lambda_api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.java_lambda_api.root_resource_id}"
  path_part   = "${var.api_path}"
}

resource "aws_api_gateway_method" "java_lambda_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  resource_id   = "${aws_api_gateway_resource.java_lambda_api_gateway.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "java_lambda_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  resource_id             = "${aws_api_gateway_resource.java_lambda_api_gateway.id}"
  http_method             = "${aws_api_gateway_method.java_lambda_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.java_lambda_function.invoke_arn}"
}

# Unfortunately the proxy resource cannot match an empty path at the root of the API.
# To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "java_lambda_method_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.java_lambda_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "java_lambda_integration_root" {
  rest_api_id = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  resource_id = "${aws_api_gateway_method.java_lambda_method_root.resource_id}"
  http_method = "${aws_api_gateway_method.java_lambda_method_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.java_lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "java_lambda_deploy" {
  depends_on  = ["aws_api_gateway_integration.java_lambda_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.java_lambda_api.id}"
  stage_name  = "${var.api_env_stage_name}"
}
