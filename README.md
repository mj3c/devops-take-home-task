# Incode take-home task

## Directory structure

## Notes

These are notes I collected as I worked on this.

1. I used the AWS Console / CLI to create some initial resources, such as an IAM user with admin privileges to avoid using the root user, the S3 bucket for terraform state, as well as the DynamoDB table for terraform state lock. These could also be done in terraform, but have to be setup in advance.

2. In a real-world scenario, I would separate this work in a few repositories, meaning the app, terraform modules, the actual terraform infra config... could all be in separate repos. This would allow for separating access control, tagging/versioning, etc... depending on requirements.

3. I used a combination of publically available modules (like the VPC module) and custom-built modules (like `./infra/modules/ecs_cluster`) to demonstrate use of both.