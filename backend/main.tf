

provider "aws" {
  region = "us-east-1"
}

// S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "resume" {
  bucket = "humdaana-cloud-portfolio-resume"
}

resource "aws_s3_bucket_website_configuration" "resume" {
  bucket = aws_s3_bucket.resume.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.resume.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-resume-bucket-name/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_ownership_controls" "resume" {
  bucket = aws_s3_bucket.resume.id
  rule {

    object_ownership = "BucketOwnerEnforced"
  }
}

// CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:243078653109:certificate/f0ddf953-ce27-49f6-be0f-90f633404984"
    ssl_support_method  = "sni-only"
  }
  
  restrictions {
  geo_restriction {
    restriction_type = "none"
  }
}
}

// Route 53 Domain Configuration
resource "aws_route53_zone" "resume_zone" {
  name = "humdaan-ahmad-portfolio.com"
}

resource "aws_route53_record" "resume_record" {
  zone_id = aws_route53_zone.resume_zone.zone_id
  name    = "humdaan-ahmad-portfolio.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

// DynamoDB Table
resource "aws_dynamodb_table" "visitor_count" {
  name           = "visitorCount"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

// IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_access" {
  name       = "lambda_dynamodb_access"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

// Lambda Function for Visitor Counter
resource "aws_lambda_function" "visitor_counter" {
  function_name    = "visitorCounter"
  role            = aws_iam_role.lambda_role.arn
  runtime        = "python3.12"
  handler        = "lambda_function.lambda_handler"

  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_count.name
    }
  }
}

// API Gateway for Lambda
resource "aws_apigatewayv2_api" "api" {
  name          = "VisitorCounterAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter.invoke_arn
}

resource "aws_apigatewayv2_route" "visitor_count_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /visitor-count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

// Lambda Permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

// Output Values
output "website_url" {
  value = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "api_url" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/visitor-count"
}
