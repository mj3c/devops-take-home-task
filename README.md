# DevOps take-home task

## Directory structure

```
.
├── demo-app                           -- The app to deploy
│   ├── Dockerfile
│   └── file.txt
├── infra                              -- The root terraform directory
│   ├── backend.tf                     -- Partial backend config
│   ├── main.tf
│   ├── modules                        -- Directory for terraform modules
│   │   ├── alb                        -- The ingress/ALB module
│   │   │   ├── certs
│   │   │   │   ├── selfsigned.crt
│   │   │   │   └── selfsigned.key
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── app                        -- The module for deploying initial resources for demo-app
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   ├── database                   -- The database (RDS) module
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── ecs_cluster                -- ECS (with EC2) module, the "worker nodes"
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── templates
│   │       │   └── ecs.sh.tpl
│   │       └── variables.tf
│   ├── terraform.eu-central-1.tfvars  -- Terraform vars file for a particular region
│   ├── variables.tf
│   └── versions.tf
└── live                               -- The live/config repo specifying what is deployed
    └── demo-app.version
```

## Notes

A few notes I collected as I worked on this.

1. I used the AWS Console / CLI to create some initial resources. These could also be done in terraform, but have to be setup in advance. These are:

    1. IAM user with admin privileges to avoid using the root user (this is just to browser the AWS console)
    1. S3 bucket for terraform state
    1. The self-signed certs for the ALB
    1. The ECR repository (could also be done inside `infra/modules/demo-app`, but usually we want a single ECR repository even if deploying to multiple regions)
    1. The IAM role to allow GitHub Actions to create AWS resources, push to ECR and update ECS services.

1. In a real-world scenario, I would most likely separate this work in a few repositories, meaning the `./demo-app`, terraform modules inside `./infra/modules`, the actual terraform infra config inside `./infra`, and the app version to deploy inside `./live` could all be in separate repos. This would allow for separating access control, tagging/versioning, etc... depending on requirements.

1. I used a combination of publically available modules (like the VPC module) and custom-built modules (like `./infra/modules/ecs_cluster`) to demonstrate use of both.

1. I've setup a self-signed cert for SSL on the ALB, in order to avoid purchasing a domain that is necessary to setup an actual ACM cert. The traffic to the ALB is encrypted, but browsers will show a warning.

1. For simplicity and automation in this project, the database password is created using Terraform and stored securely in SSM Parameter Store with KMS encryption. In a production system, I would most likely manage secrets outside of Terraform to avoid persisting them in state files. The value is not stored with other non-sensitive tfvars and is stored as a GitHub repository secret.

