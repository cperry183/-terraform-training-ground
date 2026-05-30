#!/bin/bash
set -e

echo "Lab 1 Instance Setup - Environment: ${environment}"

# Update system
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y \
  curl \
  wget \
  git \
  htop \
  net-tools \
  vim

# Install Docker (optional - for Lab 2)
apt-get install -y \
  docker.io \
  docker-compose

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create a simple health check file
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <title>Terraform Lab 1</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 40px; }
      .success { color: green; }
    </style>
  </head>
  <body>
    <h1>🎉 Lab 1: Terraform Basics</h1>
    <p class="success">EC2 instance is running successfully!</p>
    <p>Hostname: <code>$(hostname)</code></p>
    <p>Instance ID: Check AWS console</p>
  </body>
</html>
EOF

# Start a simple HTTP server (Python)
python3 -m http.server 80 --directory /var/www/html &

echo "Lab 1 setup complete!"
