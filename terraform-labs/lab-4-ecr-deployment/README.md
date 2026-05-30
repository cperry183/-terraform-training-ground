# Lab 4: ECR Deployment & Docker Image Registry

## Goal
Create and manage a Docker image registry in AWS ECR (Elastic Container Registry), push your images, and prepare for production deployments.

## What You'll Learn

1. **AWS ECR Concepts**
   - Creating repositories
   - Image scanning
   - Lifecycle policies
   - Repository access control

2. **Docker & Registry**
   - Tagging images
   - Pushing to registry
   - Image versioning
   - Registry authentication

3. **Image Management**
   - Cleanup policies
   - Image retention
   - Security scanning
   - Cost optimization

## Prerequisites

- Docker with Lab 2 image or custom image
- AWS CLI configured
- Terraform initialized

## Quick Start

```bash
cd lab-4-ecr-deployment

# Create variables
cp terraform.tfvars.example terraform.tfvars

# Deploy ECR repository
terraform init
terraform plan
terraform apply

# Get repository URL
REPO_URL=$(terraform output -raw repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $REPO_URL

# Tag and push your image
docker tag lab2-app:latest $REPO_URL:latest
docker tag lab2-app:latest $REPO_URL:v1.0.0
docker push $REPO_URL:latest
docker push $REPO_URL:v1.0.0

# Verify in ECR
aws ecr describe-images --repository-name lab4-app
```

## Exercises

### Exercise 1: Push Multiple Image Versions

```bash
REPO_URL=$(terraform output -raw repository_url)

# Build images with different tags
docker build -t lab2-app:v1.0.0 ../lab-2-docker-intro
docker build -t lab2-app:v1.0.1 ../lab-2-docker-intro
docker build -t lab2-app:latest ../lab-2-docker-intro

# Tag for ECR
docker tag lab2-app:v1.0.0 $REPO_URL:v1.0.0
docker tag lab2-app:v1.0.1 $REPO_URL:v1.0.1
docker tag lab2-app:latest $REPO_URL:latest

# Push all
docker push $REPO_URL:v1.0.0
docker push $REPO_URL:v1.0.1
docker push $REPO_URL:latest
```

### Exercise 2: Use Image in Lab 3

Update Lab 3 to use your ECR image:

```bash
cd ../lab-3-ecs-fargate

terraform apply -var="container_image=$REPO_URL:latest"

# The service will now pull from your private ECR
# Instead of public Docker Hub
```

### Exercise 3: Image Scanning

```bash
# View scan results
aws ecr describe-images --repository-name lab4-app

# Get detailed scan findings
aws ecr describe-image-scan-findings \
  --repository-name lab4-app \
  --image-id imageTag=latest
```

## Common Tasks

### Push an Image

```bash
# 1. Tag the image
docker tag local-image:tag $REPO_URL:tag

# 2. Push
docker push $REPO_URL:tag
```

### Pull an Image

```bash
# 1. Login
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $REPO_URL

# 2. Pull
docker pull $REPO_URL:latest
```

### List Images

```bash
# Via AWS CLI
aws ecr describe-images --repository-name lab4-app

# Via Docker (after login)
docker pull $REPO_URL:latest
```

### Delete Images

```bash
# Delete specific tag
aws ecr batch-delete-image \
  --repository-name lab4-app \
  --image-ids imageTag=v1.0.0

# Delete by digest
aws ecr batch-delete-image \
  --repository-name lab4-app \
  --image-ids imageDigest=sha256:xxxxx
```

## Lifecycle Policy

The Terraform configuration includes a lifecycle policy that:
- Keeps the last 10 images
- Removes untagged images after 7 days
- Helps manage storage costs

Edit in `main.tf` to customize retention.

## Cost Considerations

- **Storage**: ~$0.10 per GB per month
- **Data transfer**: Minimal for internal AWS transfers
- **Image scanning**: Included

**Typical cost for 1-5 images: <$1/month**

## Troubleshooting

**"Error: AccessDenied on ECR repository"**
- Verify IAM permissions
- Check AWS credentials: `aws sts get-caller-identity`

**"Error: docker: unauthorized"**
- Re-login to ECR
- Check token hasn't expired (valid for 12 hours)

**"Error: Repository not found"**
- Create the repository first: `terraform apply`
- Verify repository name matches

## Next Steps

1. Use ECR images in Lab 3 ECS deployments
2. Set up CI/CD to build and push images
3. Implement image signing and verification
4. Set up image scanning and vulnerability management
5. Use image pull-through cache for public images

## Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ECR/)
- [Docker Registry API](https://docs.docker.com/registry/spec/api/)
- [ECR Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security_iam_service-with-iam.html)
