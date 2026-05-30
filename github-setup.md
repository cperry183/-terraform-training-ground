# Setting Up on GitHub

This guide explains how to push your Terraform labs to GitHub and set them up for team collaboration.

## Prerequisites

- GitHub account
- Git installed locally
- Repository created on GitHub

## Step 1: Initialize Git Repository

```bash
cd terraform-labs

# Initialize git
git init

# Add GitHub origin
git remote add origin https://github.com/YOUR_USERNAME/terraform-labs.git

# Verify
git remote -v
```

## Step 2: Create Initial Commit

```bash
# Stage all files
git add .

# Check what will be committed
git status

# Commit
git commit -m "Initial commit: Add 6 Terraform labs for learning

- Lab 1: Terraform basics with EC2
- Lab 2: Docker fundamentals
- Lab 3: ECS Fargate deployment
- Lab 4: ECR image registry
- Lab 5: VPC and security (stub)
- Lab 6: State management (stub)
- Makefile for common tasks
- Comprehensive documentation"

# Push to GitHub
git push -u origin main
```

## Step 3: GitHub Repository Setup

### Protect Main Branch

1. Go to Settings → Branches
1. Add rule for `main` branch
1. Require pull request review before merging
1. Require status checks to pass

### Add .gitignore Protection

Ensure `.gitignore` prevents committing:

- `terraform.tfstate*`
- `*.tfvars` (not tfvars.example)
- `.terraform/`
- `.env`

### Configure GitHub Secrets

For CI/CD integration:

1. Go to Settings → Secrets → Actions
1. Add secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

```bash
# Example in GitHub Actions
- name: Terraform Plan
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: |
    cd ${{ matrix.lab }}
    terraform init
    terraform plan
```

## Step 4: Add GitHub Actions (CI/CD)

Create `.github/workflows/terraform.yml`:

```yaml
name: Terraform Validation

on:
  pull_request:
    paths:
      - 'lab-*/**'
      - '.github/workflows/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        lab:
          - lab-1-terraform-basics
          - lab-2-docker-intro
          - lab-3-ecs-fargate
          - lab-4-ecr-deployment

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5

      - name: Terraform Init
        run: |
          cd ${{ matrix.lab }}
          terraform init -backend=false

      - name: Terraform Validate
        run: |
          cd ${{ matrix.lab }}
          terraform validate

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

  docker-build:
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.files[*].filename, 'lab-2-docker-intro/')

    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: |
          cd lab-2-docker-intro
          docker build -t lab2-app:test .

      - name: Test Docker image
        run: |
          docker run -d -p 5000:5000 lab2-app:test
          sleep 2
          curl http://localhost:5000/health
```

## Step 5: Team Collaboration Setup

### For Remote State

Create shared Terraform state resources:

```bash
# Create state bucket
aws s3api create-bucket \
  --bucket terraform-labs-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-labs-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Create Team Backend Config

Create `shared-backends.tf`:

```hcl
# Development backend
terraform {
  backend "s3" {
    bucket         = "terraform-labs-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Step 6: Documentation

### Add TEAM_GUIDE.md

```markdown
# Team Development Guide

## Workflow

1. Create feature branch
   ```bash
   git checkout -b feature/add-rds-lab
```

1. Make changes to lab files
1. Test locally
   
   ```bash
   terraform init
   terraform plan
   ```
1. Push and create Pull Request
   
   ```bash
   git push origin feature/add-rds-lab
   ```
1. Review and merge

## Guidelines

- One feature per branch
- Write clear commit messages
- Test before pushing
- Update documentation
- Review other’s PRs
- Never commit `.tfstate` or `.tfvars`

## Remote State Access

Each team member needs:

- AWS credentials in ~/.aws/credentials
- S3 bucket read/write permissions
- DynamoDB table access

```
## Step 7: README Customization

Update root README.md with:

```markdown
# Terraform Labs

Comprehensive learning project for Terraform, Docker, and AWS.

## Getting Started

```bash
git clone https://github.com/YOUR_USERNAME/terraform-labs.git
cd terraform-labs
make help
```

## Labs

- [Lab 1: Terraform Basics](lab-1-terraform-basics/README.md)
- [Lab 2: Docker Introduction](lab-2-docker-intro/README.md)
- [Lab 3: ECS Fargate](lab-3-ecs-fargate/README.md)
- [Lab 4: ECR Deployment](lab-4-ecr-deployment/README.md)
- [Lab 5: VPC & Security](lab-5-vpc-security/README.md)
- [Lab 6: State Management](lab-6-state-management/README.md)

## Quick Start

See <QUICK_START.md>

## Team Collaboration

See <TEAM_GUIDE.md>

## Contributing

Contributions welcome! See issues for open tasks.

```
## Step 8: Push to GitHub

```bash
# Create feature branch for your changes
git checkout -b feature/github-setup

# Make any final changes
git add .
git commit -m "Add GitHub Actions and team setup"

# Push
git push origin feature/github-setup

# Create Pull Request on GitHub
```

## Step 9: GitHub Actions Troubleshooting

### View logs

1. Go to Actions tab
1. Click on workflow
1. View logs for each step

### Common issues

**Terraform not found**

```yaml
- uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.5
```

**AWS credentials not working**

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Step 10: Branch Protection

1. Go to Settings → Branches
1. Click “Add rule”
1. Branch name pattern: `main`
1. Enable:
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Dismiss stale reviews
- ✅ Restrict who can push (optional)

## Team Workflow Example

### Alice wants to add Lab 7

```bash
# Create branch
git checkout -b feature/lab-7-rds

# Create new lab
mkdir lab-7-rds-database
cd lab-7-rds-database
# Add main.tf, variables.tf, outputs.tf, README.md

# Commit
git add lab-7-rds-database/
git commit -m "Add Lab 7: RDS database integration

- VPC security group for RDS
- RDS instance configuration
- Parameter store for secrets
- Integration with Lab 3 ECS"

# Push and create PR
git push origin feature/lab-7-rds
```

### Bob reviews and approves

1. Views PR on GitHub
1. Reviews code
1. Runs locally to test
1. Approves PR
1. Merges to main

### GitHub Actions runs automatically

- Validates Terraform syntax
- Checks formatting
- Can run tests
- Prevents merge if checks fail

## Useful GitHub Features

### Labels

```bash
bug
enhancement
documentation
terraform
docker
aws
in-progress
help-wanted
```

### Milestones

- v1.0: Core labs complete
- v1.1: Advanced topics
- v2.0: Team features

### Discussions

Enable for:

- Questions about labs
- Ideas for new content
- Troubleshooting help

### Projects

Track progress:

- Backlog
- In Progress
- Done

## Security Best Practices

1. **Don’t commit secrets**
- .tfvars files in .gitignore
- Use AWS Secrets Manager
- GitHub Secrets for CI/CD
1. **Branch protection**
- Require reviews before merge
- Require status checks
- Dismiss stale reviews
1. **Access control**
- Use GitHub Teams
- Set appropriate permissions
- Audit access regularly
1. **Audit trail**
- Enable GitHub audit logs
- Review Actions workflows
- Check sensitive file access

## Maintenance

### Regular tasks

```bash
# Update dependencies
# Check for deprecated Terraform features
# Review and merge open PRs
# Archive old branches
# Update documentation

# Monthly
git log --oneline # Review commits
git branch -vv    # Check branch status
```

## Resources

- [GitHub Documentation](https://docs.github.com)
- [GitHub Actions](https://docs.github.com/actions)
- [Terraform Registry](https://registry.terraform.io)
- [AWS Documentation](https://docs.aws.amazon.com)

-----

**Questions?** Create an issue on GitHub or start a discussion!