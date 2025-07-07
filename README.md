# Incode take-home task

## Directory structure

## Notes

These are notes I collected as I worked on this.

1. I used the AWS Console / CLI to create some initial resources. These could also be done in terraform, but have to be setup in advance. These are:

  1. IAM user with admin privileges to avoid using the root user
  2. S3 bucket for terraform state + DynamoDB table for state lock
  3. The self-signed certs for the ALB

2. In a real-world scenario, I would separate this work in a few repositories, meaning the app, terraform modules, the actual terraform infra config... could all be in separate repos. This would allow for separating access control, tagging/versioning, etc... depending on requirements.

3. I used a combination of publically available modules (like the VPC module) and custom-built modules (like `./infra/modules/ecs_cluster`) to demonstrate use of both.

4. I've setup a self-signed cert for SSL on the ALB, in order to avoid purchasing a domain that is necessary to setup an actual ACM cert. The traffic to the ALB is encrypted, but browsers will show a warning.

5. For simplicity and automation in this project, the database password is created using Terraform and stored securely in SSM Parameter Store with KMS encryption. In a production system, I would most likely manage secrets outside of Terraform to avoid persisting them in state files. The value is not stored with other non-sensitive tfvars and is stored inside GitHub Actions variables.

