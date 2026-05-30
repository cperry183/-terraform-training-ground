# Quick Start Guide

Get up and running with Terraform in 10 minutes.

## Prerequisites

```bash
# Verify Terraform is installed
terraform --version    # Should be >= 1.5

# Verify AWS CLI is configured
aws sts get-caller-identity

# Verify Docker (optional, needed for Labs 2-4)
docker --version
```

## 5-Minute Quick Start

### Lab 1: Simple EC2 Instance

```bash
cd lab-1-terraform-basics

# Create your variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars - add your EC2 Key Pair name
nano terraform.tfvars
# Set: key_name = "your-existing-key-pair-name"

# Initialize and plan
terraform init
terraform plan

# Apply (creates resources)
terraform apply

# View outputs
terraform output

# Cleanup (destroys resources)
terraform destroy
```

**Time: 5 minutes | Cost: ~$0.01**

---

### Lab 2: Docker Basics (No AWS required)

```bash
cd lab-2-docker-intro

# Build the image
docker build -t lab2-app:latest .

# Run the container
docker run -d --name lab2-container -p 5000:5000 lab2-app:latest

# Test it
curl http://localhost:5000/health

# View logs
docker logs lab2-container

# Stop
docker stop lab2-container
docker rm lab2-container
```

**Time: 3 minutes | Cost: $0.00**

---

### Lab 3: Deploy to AWS ECS

```bash
cd lab-3-ecs-fargate

# Create variables
cp terraform.tfvars.example terraform.tfvars

# Edit and set container_image (can use nginx:latest for testing)
nano terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply

# Get the URL
terraform output alb_url

# Test it
curl $(terraform output -raw alb_url)/health

# Cleanup
terraform destroy
```

**Time: 10 minutes | Cost: ~$0.50**

---

## Using the Makefile

```bash
# Show all available commands
make help

# Initialize Lab 1
make init LAB=lab-1-terraform-basics

# Plan Lab 3
make plan LAB=lab-3-ecs-fargate

# Build Docker image for Lab 2
make docker-build LAB=lab-2-docker-intro

# Run Lab 2 with Docker Compose
make docker-compose LAB=lab-2-docker-intro
```

---

## Recommended Learning Path

1. **Start with Lab 1** (15 min)
   - Understand Terraform basics
   - Learn variables, state, outputs
   - Simple EC2 creation

2. **Try Lab 2** (20 min)
   - Build Docker images
   - Run containers locally
   - Understand containerization

3. **Do Lab 3** (30 min)
   - Deploy containers to AWS
   - Load balancing
   - Auto-scaling concepts

4. **Continue with Labs 4-6** (advanced)
   - ECR image registry
   - Production VPC setup
   - State management

---

## Common Issues

**"Error: Access Denied on AWS resource"**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam get-user
```

**"Port already in use"**
```bash
# Docker: Use different port
docker run -p 5001:5000 lab2-app:latest

# Check what's using the port
lsof -i :5000
```

**"terraform.lock.hcl conflicts"**
```bash
# Delete and reinit
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

## Tips

1. **Always use `terraform plan` first** - See what will change
2. **Save your outputs** - They contain important URLs and IDs
3. **Check logs** - `terraform -chdir=LAB apply` shows detailed output
4. **Use `terraform destroy`** - Clean up to avoid AWS charges
5. **Read error messages** - They're usually very descriptive

---

## Environment Variables

```bash
# Set AWS region
export AWS_REGION=us-west-2

# Enable debug logging
export TF_LOG=DEBUG

# Specify custom variables file
terraform apply -var-file=custom.tfvars

# Use environment variables for sensitive data
export TF_VAR_key_name=my-key
terraform apply
```

---

## Next Steps After Quick Start

- Read the detailed README.md in each lab
- Explore the Terraform configuration files
- Modify variables and see what changes
- Check AWS Console to see created resources
- Review CloudWatch logs
- Test auto-scaling
- Build your own labs

---

## Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Docs](https://docs.docker.com/)
- [AWS ECS Docs](https://docs.aws.amazon.com/ecs/)

---

**Questions?** Check the README.md in each lab for detailed explanations.

**Want to contribute?** PRs welcome! Add new labs, improve docs, fix bugs.
