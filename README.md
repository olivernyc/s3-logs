# S3 Logs

Sends an SMS notification when log files are added to an S3 bucket.

## Getting Started

Initialize Terraform: `terraform init`

Add AWS credentials by creating a file `.aws/credentials` with the following format

```
[default]
aws_access_key_id=AKIAI5ZFWexamplekey
aws_secret_access_key=bTDX3BabY8S6yltMCu7nGNatZO1uukexamplekey
```

Naviate to `lambda` and install dependencies: `yarn`

Add environment variables to `lambda/.env`:

```
TWILIO_SID="ACd2596beaf7da2a18e6c3c5examplesid"
TWILIO_TOKEN="20f80e42b8c0064510d4exampletoken"
FROM_NUMBER="+123456789"
TO_NUMBER="+987654321"
```

Apply Terraform configuration: `terraform apply`

## Design / Assumptions

The S3 bucket sends [S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html) to a Lambda function which calls the Twilio API. This assumes the volume of logs is in the millions per month or below. At higher scales it may become more economical / performant to process the notifications with an EC2 instance.

The S3 notification uses a suffix filter so it will only trigger on files that end with `.log`.

## Testing

Navigate to the `lambda` directory and run `yarn test`. This will send a mock S3 event to the Lambda function and verify a successful response from Twilio. Integration testing is currently done manually, by uploading a .log file to the bucket in the AWS console.

## Deployment / Automation

All cloud resources are defined using Terraform in `main.tf`. Currently deployment is done locally, with the `terraform apply` command. With more time, this would be moved to a CI step.

## Operational Supportability

The Lambda function can be monitored in the AWS CloudWatch dashboard.

## Issues

-   Cold boot times are around ~1 second. If latency is an issue, it might make more sense to run this on EC2.
-   Lambda deployment is done by zipping entire directory and uploading with Terraform, which is pretty hacky. Would be better to move this to a build step in the CI pipeline, using Webpack and proper secret management.
