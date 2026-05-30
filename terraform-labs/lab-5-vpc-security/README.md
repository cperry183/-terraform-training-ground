# Lab 5: VPC & Security - Production Networking

## Goal
Design and implement a production-grade VPC with proper security controls, networking architecture, and IAM policies.

## What You'll Learn

1. **VPC Architecture**
   - VPC creation and subnets
   - Public, private, and protected subnets
   - NAT gateways and bastion hosts
   - Route tables and route propagation

2. **Security Concepts**
   - Security groups
   - Network ACLs
   - VPC endpoints
   - Private link

3. **IAM & Access Control**
   - IAM roles and policies
   - Service principals
   - Cross-account access
   - Least privilege principles

4. **Monitoring & Logging**
   - VPC Flow Logs
   - CloudTrail
   - Security group monitoring
   - NAT gateway metrics

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│ VPC (10.0.0.0/16)                                   │
│                                                      │
│ ┌──────────────────────────────────────────────────┐│
│ │ Public Subnet (10.0.1.0/24)                      ││
│ │ ┌─────────────┐  ┌─────────────┐                ││
│ │ │ NAT Gateway │  │ Bastion Host│                ││
│ │ └─────────────┘  └─────────────┘                ││
│ └──────────────────────────────────────────────────┘│
│                                                      │
│ ┌──────────────────────────────────────────────────┐│
│ │ Private Subnet (10.0.2.0/24)                     ││
│ │ ┌─────────────┐  ┌─────────────┐                ││
│ │ │ EC2 Instance│  │ ECS Task    │                ││
│ │ └─────────────┘  └─────────────┘                ││
│ └──────────────────────────────────────────────────┘│
│                                                      │
│ ┌──────────────────────────────────────────────────┐│
│ │ Database Subnet (10.0.3.0/24)                    ││
│ │ ┌─────────────┐  ┌─────────────┐                ││
│ │ │ RDS Instance│  │ ElastiCache │                ││
│ │ └─────────────┘  └─────────────┘                ││
│ └──────────────────────────────────────────────────┘│
│                                                      │
└─────────────────────────────────────────────────────┘
```

## Labs in This Section

- **Lab 5a**: Basic VPC with subnets
- **Lab 5b**: Security groups and NACLs
- **Lab 5c**: Bastion host and SSH access
- **Lab 5d**: Private RDS database
- **Lab 5e**: VPC endpoints and security

## Getting Started

```bash
cd lab-5-vpc-security

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Plan VPC creation
terraform init
terraform plan

# Deploy
terraform apply
```

## Exercises

### Exercise 1: Create VPC with Subnets

```bash
terraform apply -var="enable_nat_gateway=true"
```

### Exercise 2: Deploy Bastion Host

```bash
terraform apply \
  -var="enable_bastion=true" \
  -var="bastion_key_name=your-key"
```

### Exercise 3: Private Database

```bash
terraform apply \
  -var="enable_rds=true" \
  -var="db_name=mydb" \
  -var="db_master_username=admin"
```

### Exercise 4: Monitor Traffic

```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /vpc/flow-logs
```

## Key Resources

- VPC: Custom IP range
- Subnets: Public, Private, Database
- Internet Gateway: Outbound internet access
- NAT Gateway: Private subnet outbound access
- Bastion Host: Secure SSH jump box
- Security Groups: Application-level firewall
- Network ACLs: Subnet-level firewall
- Route Tables: Network routing rules

## IAM Policies

The configuration creates appropriate IAM roles for:
- EC2 instances (parameter store, S3 access)
- ECS tasks (ECR pull, secrets)
- RDS (encrypted backups)
- Lambda (VPC execution)

## Monitoring

```bash
# View VPC Flow Logs
aws logs tail /vpc/flow-logs --follow

# Check security group rules
aws ec2 describe-security-groups

# Monitor NAT gateway
aws cloudwatch get-metric-statistics \
  --namespace AWS/NatGateway \
  --metric-name BytesOutToDestination
```

## Cost Estimates

- **VPC**: Free
- **NAT Gateway**: ~$32/month
- **Bastion (t3.micro)**: ~$5/month (free tier)
- **RDS**: ~$30-100/month depending on instance

## Best Practices

1. Use private subnets for databases
2. Implement least privilege in security groups
3. Enable VPC Flow Logs for auditing
4. Use NACLs for additional protection
5. Implement bastion host for admin access
6. Use Secrets Manager for sensitive data
7. Enable VPC endpoint for AWS services

## Next Steps

- Integrate with Lab 3 ECS deployment
- Add RDS database
- Implement ElastiCache
- Set up VPN/Direct Connect
- Implement Application Load Balancer

## Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Terraform AWS VPC](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/)
