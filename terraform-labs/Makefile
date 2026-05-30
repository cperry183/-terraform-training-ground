.PHONY: help init plan apply destroy fmt validate clean test docker-build docker-push

LAB ?= lab-1-terraform-basics
AWS_REGION ?= us-east-1

help:
	@echo "Terraform Labs - Available Commands"
	@echo "===================================="
	@echo ""
	@echo "General Commands:"
	@echo "  make help              Show this help message"
	@echo "  make clean             Remove .terraform and state files"
	@echo ""
	@echo "Terraform Commands (use LAB=lab-X):"
	@echo "  make init              Initialize Terraform"
	@echo "  make validate          Validate Terraform configuration"
	@echo "  make fmt               Format Terraform files"
	@echo "  make plan              Plan changes"
	@echo "  make apply             Apply changes"
	@echo "  make destroy           Destroy resources"
	@echo "  make state             Show Terraform state"
	@echo ""
	@echo "Docker Commands (Lab 2):"
	@echo "  make docker-build      Build Docker image"
	@echo "  make docker-run        Run Docker container"
	@echo "  make docker-test       Test Docker container"
	@echo "  make docker-compose    Run Docker Compose"
	@echo ""
	@echo "Examples:"
	@echo "  make init LAB=lab-1-terraform-basics"
	@echo "  make plan LAB=lab-3-ecs-fargate"
	@echo "  make docker-build LAB=lab-2-docker-intro"
	@echo ""

init:
	@echo "Initializing $(LAB)..."
	cd $(LAB) && terraform init

validate:
	@echo "Validating $(LAB)..."
	cd $(LAB) && terraform validate

fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

plan:
	@echo "Planning changes for $(LAB)..."
	cd $(LAB) && terraform plan

apply:
	@echo "Applying changes to $(LAB)..."
	cd $(LAB) && terraform apply

destroy:
	@echo "Destroying resources in $(LAB)..."
	cd $(LAB) && terraform destroy

state:
	@echo "Terraform state for $(LAB):"
	cd $(LAB) && terraform state list

clean:
	@echo "Cleaning up..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfstate*" -delete
	find . -name ".terraform.lock.hcl" -delete
	@echo "Cleanup complete"

docker-build:
	@echo "Building Docker image for $(LAB)..."
	@if [ -f "$(LAB)/Dockerfile" ]; then \
		docker build -t $(LAB):latest $(LAB); \
	else \
		echo "No Dockerfile found in $(LAB)"; \
	fi

docker-run:
	@echo "Running Docker container for $(LAB)..."
	docker run -d \
		--name $(LAB)-container \
		-p 5000:5000 \
		-e ENVIRONMENT=development \
		$(LAB):latest

docker-test:
	@echo "Testing Docker container..."
	sleep 2
	curl -s http://localhost:5000/ | jq . || echo "Container not responding"
	docker logs $(LAB)-container

docker-compose:
	@echo "Running Docker Compose for $(LAB)..."
	@if [ -f "$(LAB)/docker-compose.yml" ]; then \
		cd $(LAB) && docker-compose up -d; \
	else \
		echo "No docker-compose.yml found in $(LAB)"; \
	fi

docker-stop:
	@echo "Stopping Docker containers..."
	docker stop $(LAB)-container 2>/dev/null || true
	docker rm $(LAB)-container 2>/dev/null || true
	@if [ -f "$(LAB)/docker-compose.yml" ]; then \
		cd $(LAB) && docker-compose down; \
	fi

# Lab-specific helpers
lab1-setup:
	@echo "Setting up Lab 1..."
	cp lab-1-terraform-basics/terraform.tfvars.example lab-1-terraform-basics/terraform.tfvars
	@echo "Edit lab-1-terraform-basics/terraform.tfvars with your key_name"

lab2-build:
	make docker-build LAB=lab-2-docker-intro

lab2-run:
	make docker-compose LAB=lab-2-docker-intro

lab3-plan:
	@echo "Planning Lab 3 deployment..."
	cp lab-3-ecs-fargate/terraform.tfvars.example lab-3-ecs-fargate/terraform.tfvars
	@echo "Edit lab-3-ecs-fargate/terraform.tfvars with your image URL"
	make plan LAB=lab-3-ecs-fargate

# AWS helpers
aws-status:
	@echo "AWS Account Information:"
	aws sts get-caller-identity
	@echo ""
	@echo "Default Region: $(AWS_REGION)"

aws-regions:
	@echo "Available AWS Regions:"
	aws ec2 describe-regions --region $(AWS_REGION) \
		--query 'Regions[].RegionName' \
		--output text | tr '\t' '\n'

# Linting
lint:
	@echo "Linting Terraform files..."
	cd $(LAB) && terraform validate
	terraform fmt -check -recursive

test:
	@echo "Running tests..."
	@echo "Validating all labs..."
	@for lab in lab-*; do \
		echo "Testing $$lab..."; \
		cd $$lab && terraform validate && cd ..; \
	done

# Quick start
quickstart: lab1-setup lab2-build
	@echo "Quickstart setup complete!"
	@echo "Next steps:"
	@echo "1. Lab 1: cd lab-1-terraform-basics && terraform init && terraform plan"
	@echo "2. Lab 2: make docker-run LAB=lab-2-docker-intro"
	@echo "3. Lab 3: Follow Lab 3 README"
