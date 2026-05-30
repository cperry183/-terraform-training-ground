# Lab 2: Docker Introduction

## Goal
Understand Docker fundamentals and containerization before integrating with Terraform and AWS.

## Prerequisites
- Docker installed: `docker --version`
- Docker Compose installed: `docker-compose --version`

## What You'll Learn

1. **Docker Basics**
   - Building images from Dockerfiles
   - Running containers
   - Managing images and containers
   - Container networking

2. **Docker Compose**
   - Multi-container orchestration
   - Service definitions
   - Health checks
   - Environment variables

3. **Best Practices**
   - Minimal base images
   - Health checks
   - Layer caching
   - Security considerations

## Exercises

### Exercise 1: Build a Docker Image

```bash
# Build the image
docker build -t lab2-app:latest .

# List images
docker images | grep lab2

# Inspect the image
docker image inspect lab2-app:latest
```

**What happened?**
- Docker read the Dockerfile
- Downloaded Python 3.11 base image
- Installed dependencies
- Created a layered image

### Exercise 2: Run a Container

```bash
# Run the container
docker run -d \
  --name lab2-container \
  -p 5000:5000 \
  -e ENVIRONMENT=development \
  -e APP_VERSION=1.0.0 \
  lab2-app:latest

# Check logs
docker logs lab2-container

# Check health
docker ps

# Test the app
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/info

# Execute command inside container
docker exec lab2-container python --version
```

### Exercise 3: Inspect and Debug

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View container processes
docker top lab2-container

# View container stats
docker stats lab2-container

# View container logs
docker logs -f lab2-container

# Inspect container details
docker inspect lab2-container
```

### Exercise 4: Docker Compose

```bash
# Start services
docker-compose up -d

# View services
docker-compose ps

# View logs
docker-compose logs -f app

# Test the application
curl http://localhost:5000/
curl http://localhost:5000/info

# Access the service from another container
docker-compose exec app curl http://redis:6379

# Scaling (run multiple instances)
docker-compose up -d --scale app=3

# Stop and remove
docker-compose down
```

### Exercise 5: Image Optimization

```bash
# Check image size before optimization
docker images lab2-app:latest

# View layers
docker history lab2-app:latest

# Multi-stage build exercise:
# Uncomment the multi-stage section in Dockerfile
# and rebuild:
docker build -t lab2-app:optimized .

# Compare sizes
docker images | grep lab2
```

### Exercise 6: Container Networking

```bash
# Create a custom network
docker network create lab2-net

# Run container on the network
docker run -d \
  --name app1 \
  --network lab2-net \
  -e ENVIRONMENT=production \
  lab2-app:latest

# Run another container on same network
docker run -d \
  --name app2 \
  --network lab2-net \
  lab2-app:latest

# Test inter-container communication
docker exec app1 curl http://app2:5000/health

# Inspect the network
docker network inspect lab2-net

# Cleanup
docker network rm lab2-net
```

## Docker Commands Reference

```bash
# Image operations
docker build -t name:tag .              # Build image
docker images                           # List images
docker tag source:tag dest:tag          # Tag image
docker push registry/name:tag           # Push to registry
docker pull image:tag                   # Pull from registry
docker rmi image:tag                    # Remove image

# Container operations
docker run [options] image              # Run container
docker ps                               # List running containers
docker ps -a                            # List all containers
docker logs container                   # View logs
docker exec -it container cmd           # Execute command
docker stop container                   # Stop container
docker rm container                     # Remove container
docker pause container                  # Pause container
docker unpause container                # Resume container

# Network operations
docker network ls                       # List networks
docker network create name              # Create network
docker network inspect name             # Inspect network
docker network rm name                  # Remove network

# Volume operations
docker volume ls                        # List volumes
docker volume create name               # Create volume
docker volume inspect name              # Inspect volume
docker volume rm name                   # Remove volume
```

## Common Issues & Solutions

**Port already in use**
```bash
# Find container using port 5000
docker ps -a
lsof -i :5000
# Kill the process or use different port
docker run -p 5001:5000 lab2-app:latest
```

**Out of disk space**
```bash
# Clean up Docker
docker system prune -a
docker image prune -a
```

**Container exits immediately**
```bash
# Check logs
docker logs container-name
# Run with terminal attached
docker run -it lab2-app:latest /bin/bash
```

**Network issues**
```bash
# Verify container can reach external resources
docker exec container-name curl google.com
# Check DNS
docker exec container-name cat /etc/resolv.conf
```

## Next Steps

- Proceed to Lab 3 to deploy this Docker image to AWS ECS
- Learn about Docker registries (ECR)
- Understand container orchestration patterns
- Explore Kubernetes concepts

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
