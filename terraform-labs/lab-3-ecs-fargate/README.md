# Lab 3: ECS Fargate with Docker

## Goal
Deploy your Docker containers to AWS ECS (Elastic Container Service) using Fargate - a serverless container orchestration platform.

## What You'll Learn

1. **ECS Concepts**
   - Clusters and services
   - Task definitions
   - Fargate launch type
   - Container orchestration

2. **Load Balancing**
   - Application Load Balancer (ALB)
   - Target groups
   - Health checks
   - Traffic distribution

3. **Networking & Security**
   - Security groups
   - VPC configuration
   - Container communication

4. **Monitoring**
   - CloudWatch logs
   - ECS metrics
   - Service health

5. **Auto Scaling**
   - Target tracking policies
   - CPU/Memory based scaling
   - Desired count management

## Architecture

```
                                    ┌──────────────┐
                                    │   Internet   │
                                    └──────┬───────┘
                                           │
                                    ┌──────▼───────┐
                                    │     ALB      │
                                    │(Port 80)     │
                                    └──────┬───────┘
                                           │
                        ┌──────────────────┼──────────────────┐
                        │                  │                  │
                  ┌─────▼────┐      ┌─────▼────┐      ┌─────▼────┐
                  │  Task 1   │      │  Task 2   │      │  Task N   │
                  │ Container │      │ Container │      │ Container │
                  │(Fargate)  │      │(Fargate)  │      │(Fargate)  │
                  └───────────┘      └───────────┘      └───────────┘
                        │                  │                  │
                        └──────────────────┼──────────────────┘
                                           │
                                    ┌──────▼───────┐
                                    │ECS Cluster   │
                                    └──────────────┘
```

## Prerequisites

1. Docker image available (from Lab 2 or public image)
2. AWS account with appropriate permissions
3. Terraform >= 1.5

## Step-by-Step Guide

### Step 1: Prepare Your Docker Image

You have two options:

**Option A: Use Lab 2 image (if you completed Lab 2)**

First, push your Lab 2 image to ECR or Docker Hub:

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name lab2-app --region us-east-1

# Tag your local image
docker tag lab2-app:latest \
  ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/lab2-app:latest

# Push to ECR
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/lab2-app:latest
```

**Option B: Use a public image (easier for learning)**

```
nginx:latest
nginx:alpine
httpbin.org/image
python:3.11-slim
```

### Step 2: Configure Terraform

```bash
cd lab-3-ecs-fargate

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and set:
# - container_image: Your Docker image URL
# - container_port: Port your container listens on (usually 5000 for Lab 2)
# - task_cpu, task_memory: Resource allocation
```

### Step 3: Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan

# Review the plan carefully - look for:
# - ECS cluster creation
# - Task definition
# - Load balancer
# - Service configuration
```

### Step 4: Deploy

```bash
# Apply changes
terraform apply

# Terraform will output the ALB DNS name
# Example output:
# alb_dns_name = "lab3-alb-123456789.us-east-1.elb.amazonaws.com"
```

### Step 5: Verify Deployment

```bash
# Get the ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test the application
curl http://$ALB_DNS/
curl http://$ALB_DNS/health

# Monitor logs (from Lab 2 app)
aws logs tail /ecs/lab3-app --follow

# Check ECS service status
aws ecs list-services --cluster lab3-cluster
aws ecs describe-services \
  --cluster lab3-cluster \
  --services lab3-service

# View task details
aws ecs list-tasks --cluster lab3-cluster
aws ecs describe-tasks \
  --cluster lab3-cluster \
  --tasks task-arn
```

## Exercises

### Exercise 1: Scale Up the Service

```bash
# Manually scale to 4 tasks
terraform apply -var="desired_count=4"

# Watch tasks start
aws ecs describe-services \
  --cluster lab3-cluster \
  --services lab3-service \
  --query 'services[0].{Name:serviceName,Status:status,DesiredCount:desiredCount,RunningCount:runningCount}'

# Load balancer distributes traffic across all tasks
watch "curl -s http://$(terraform output -raw alb_dns_name)/info | jq ."
```

### Exercise 2: Update the Task Definition

```bash
# Change container image (e.g., use different version)
terraform apply -var="container_image=nginx:alpine"

# This triggers a rolling update - old tasks stop, new tasks start
# Service maintains traffic during update

# Monitor the update
aws ecs describe-services \
  --cluster lab3-cluster \
  --services lab3-service \
  --query 'services[0].deployments'
```

### Exercise 3: Monitor Auto Scaling

```bash
# Current configuration auto-scales on CPU/memory
# Force load on the application

# First, get the ALB URL
ALB_DNS=$(terraform output -raw alb_dns_name)

# Generate load (install Apache Bench)
ab -n 10000 -c 100 http://$ALB_DNS/

# Watch service scale up
watch aws ecs describe-services \
  --cluster lab3-cluster \
  --services lab3-service

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=lab3-service \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average
```

### Exercise 4: View Logs

```bash
# CloudWatch logs for the service
aws logs tail /ecs/lab3-app --follow

# Filter logs from specific task
aws logs filter-log-events \
  --log-group-name /ecs/lab3-app \
  --query 'events[*].[timestamp,message]' \
  --output text

# Export logs for analysis
aws logs get-log-events \
  --log-group-name /ecs/lab3-app \
  --log-stream-name ecs/app/task-id
```

### Exercise 5: Implement Canary Deployment

Change the task definition in `main.tf` to support blue-green deployments:

```bash
# Step 1: Update container image
terraform apply -var="container_image=your-new-image:v2"

# Step 2: Monitor deployment progress
# ECS uses rolling update strategy by default
# Old tasks gradually replaced with new ones

# Step 3: If issues, rollback
terraform apply -var="container_image=your-old-image:v1"
```

## Troubleshooting

### Tasks not reaching healthy state

```bash
# Check task logs
aws logs tail /ecs/lab3-app --follow

# Verify health check configuration
aws ecs describe-task-definition \
  --task-definition lab3-app \
  --query 'taskDefinition.containerDefinitions[0].healthCheck'

# Test health check manually
curl http://ALB_DNS/health
```

### Load balancer not routing traffic

```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# Verify security groups allow traffic
aws ec2 describe-security-groups \
  --group-ids sg-xxxx
```

### Service fails to start

```bash
# Check IAM role
aws iam get-role --role-name lab3-ecs-task-execution-role

# Verify task role permissions
aws iam list-role-policies --role-name lab3-ecs-task-role

# Check task definition
aws ecs describe-task-definition \
  --task-definition lab3-app
```

### Out of capacity

```bash
# If using FARGATE_SPOT, switch to FARGATE
# Edit main.tf and use only FARGATE capacity provider

# Or increase max_capacity
terraform apply -var="max_capacity=10"
```

## Key Concepts

### Fargate vs EC2
- **Fargate**: Serverless containers, pay per task, no instance management
- **EC2**: Manage instances yourself, better for cost optimization

### Task Definition
- Defines Docker image, CPU, memory, environment variables
- Version controlled automatically
- Can be reused across services

### ECS Service
- Keeps desired number of tasks running
- Integrates with load balancers
- Handles rolling updates
- Monitors task health

### Auto Scaling
- Target tracking policies
- Scales based on CloudWatch metrics
- Cooldown periods to prevent flapping

## AWS Costs

This lab uses:
- ECS Fargate: ~$0.05-0.10/hour per task
- Application Load Balancer: ~$16/month base + data charges
- CloudWatch Logs: minimal (~$0.50/month for small logs)

**Estimated monthly cost: $30-50 for dev environment**

## Next Steps

1. Complete Lab 4: ECR + Docker image registry
2. Implement production networking (Lab 5)
3. Add RDS database
4. Implement Secrets Manager for credentials
5. Set up CI/CD pipeline

## Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [ECS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html)
- [Terraform ECS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/best_practices.html)
