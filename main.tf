provider "aws" {
  region = "ap-southeast-2"
  shared_credentials_file = ".aws/credentials"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "build/index.js.zip"
  source_dir  = "lambda"
}

resource "aws_lambda_function" "bucket_notification" {
  function_name    = "handle_bucket_notification"
  filename         = "build/index.js.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda.arn
}

resource "aws_s3_bucket" "log" {
  bucket = "s3-log-bucket.operata.com"
  acl    = "public-read-write"
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bucket_notification.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.log.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.log.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.bucket_notification.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.lambda]
}