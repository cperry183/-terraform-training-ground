# Lab 6: Terraform State Management

## Goal
Master Terraform state management for team environments, implement remote state, state locking, and backup strategies.

## What You'll Learn

1. **State Fundamentals**
   - What is Terraform state
   - Local vs remote state
   - State locking
   - State migration

2. **Backend Configuration**
   - S3 backend setup
   - DynamoDB state locking
   - Backend security
   - Encryption at rest

3. **Team Workflows**
   - Shared state configuration
   - Workspace management
   - State isolation
   - Collaboration patterns

4. **Advanced Topics**
   - State file recovery
   - Sensitive data protection
   - Multi-region deployments
   - Cross-account access

## Architecture

```
┌──────────────────────────────────────────────────────┐
│ Developer Workstations                               │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│ │ Terminal │  │ Terminal │  │ Terminal │           │
│ │  Alice   │  │   Bob    │  │  Carol   │           │
│ └────┬─────┘  └────┬─────┘  └────┬─────┘           │
└─────┼─────────────────┼─────────────┼────────────────┘
      │                 │             │
      │  terraform apply│terraform plan│
      └─────────────────┼─────────────┘
                        │
            ┌───────────▼────────────┐
            │ S3 Backend (State)     │
            │ ┌────────────────────┐ │
            │ │ terraform.tfstate  │ │
            │ │ (encrypted)        │ │
            │ └────────────────────┘ │
            └───────────┬────────────┘
                        │
            ┌───────────▼────────────┐
            │ DynamoDB Lock Table    │
            │ ┌────────────────────┐ │
            │ │ Lock State         │ │
            │ │ (prevent conflicts)│ │
            │ └────────────────────┘ │
            └────────────────────────┘
```

## Prerequisites

- AWS S3 bucket access
- DynamoDB access
- Terraform >= 1.5

## State Basics

### Local State (Default)

```bash
# Terraform stores state locally
ls -la terraform.tfstate

# Problems:
# - No sharing between team members
# - No backup/recovery
# - Sensitive data in plaintext
# - Concurrent access conflicts
```

### Remote State (Production)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Setting Up Remote State

### Step 1: Create S3 Bucket

```bash
aws s3api create-bucket \
  --bucket terraform-state-$(date +%s) \
  --region us-east-1
```

### Step 2: Enable Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-xxx \
  --versioning-configuration Status=Enabled
```

### Step 3: Create DynamoDB Table

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Step 4: Configure Backend

Create `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-bucket-name"
    key            = "env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Step 5: Migrate State

```bash
# Initialize with new backend
terraform init

# Terraform will ask to copy state - answer "yes"
# Local state migrates to S3
rm terraform.tfstate*
```

## Exercises

### Exercise 1: Setup Remote State

```bash
cd lab-6-state-management

# Follow the steps above to set up S3 and DynamoDB

# Copy example backend config
cp backend.tf.example backend.tf

# Edit with your values
nano backend.tf

# Initialize
terraform init
```

### Exercise 2: Workspace Isolation

```bash
# Create workspaces for different environments
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform apply

terraform workspace select prod
terraform apply

# Different state files per workspace
# dev:     s3://bucket/env:/dev/terraform.tfstate
# prod:    s3://bucket/env:/prod/terraform.tfstate
```

### Exercise 3: State Locking

```bash
# Terminal 1: Start a long operation
terraform apply &

# Terminal 2: Try to apply while locked
terraform apply
# Should wait for lock to be released

# View lock in DynamoDB
aws dynamodb scan --table-name terraform-locks
```

### Exercise 4: State Recovery

```bash
# View state history
aws s3api list-object-versions \
  --bucket terraform-state-xxx \
  --prefix prod/

# Restore previous version
aws s3api get-object \
  --bucket terraform-state-xxx \
  --key prod/terraform.tfstate \
  --version-id XXXXX \
  terraform.tfstate.backup

# Review and apply if needed
terraform apply -refresh=false
```

## Key Commands

```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new staging

# Select workspace
terraform workspace select staging

# View state
terraform state list
terraform state show aws_instance.example

# Move resource between workspaces
terraform state mv -state=../backup/terraform.tfstate \
  aws_instance.example \
  aws_instance.moved

# Remove from state (without destroying)
terraform state rm aws_instance.example

# Pull remote state locally
terraform state pull > backup.tfstate

# Push local state to remote
terraform state push backup.tfstate
```

## Best Practices

1. **Always use remote state** in production
2. **Enable encryption** at rest and in transit
3. **Use state locking** to prevent conflicts
4. **Enable versioning** on S3 for recovery
5. **Restrict access** to state bucket (IAM)
6. **Backup regularly** (versioning handles this)
7. **Never commit state files** to git
8. **Use workspaces** for environment isolation
9. **Rotate access keys** regularly
10. **Audit access** with CloudTrail

## Security

### Protect State Bucket

```hcl
# Block public access
resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable logging
resource "aws_s3_bucket_logging" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "terraform-state-logs/"
}
```

## Troubleshooting

**"Error: Backend initialization required"**
```bash
# Remove local backend config
rm .terraform/terraform.tfstate
terraform init
```

**"Error: Error acquiring the state lock"**
```bash
# View locks
aws dynamodb scan --table-name terraform-locks

# Force unlock (DANGEROUS - only if needed)
terraform force-unlock LOCK_ID
```

**"Error: No such file or directory: .terraform/terraform.tfstate"**
```bash
# Remote state not initialized
terraform init
```

## Monitoring State

```bash
# Enable CloudTrail
aws cloudtrail create-trail \
  --name terraform-state-trail \
  --s3-bucket-name my-cloudtrail-logs

# Monitor S3 access
aws cloudwatch put-metric-alarm \
  --alarm-name high-state-access \
  --metric-name NumberOfObjects \
  --namespace AWS/S3
```

## Advanced Topics

- Cross-account state access
- Multi-region deployments
- Terraform Cloud/Enterprise
- State encryption with KMS
- Automated backups
- State analytics

## Resources

- [Terraform State Documentation](https://www.terraform.io/language/state)
- [S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)
- [Terraform Cloud](https://www.terraform.io/cloud)
- [State Migration](https://www.terraform.io/cli/commands/state/mv)
