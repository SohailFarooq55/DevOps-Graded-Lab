#!/bin/bash

echo "===== Starting DevOps Provisioning ====="

# Install Docker only if it is missing
if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing Docker..."

    dnf -y install dnf-plugins-core

    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker is already installed."
fi

# Start and enable Docker
systemctl enable --now docker

# Remove old container if it exists
if docker ps -a --format '{{.Names}}' | grep -q '^devops-web$'
then
    echo "Removing existing devops-web container..."
    docker rm -f devops-web
fi

# Run nginx container
echo "Starting devops-web container..."

docker run -d \
    --name devops-web \
    -p 80:80 \
    -v /vagrant/website:/usr/share/nginx/html:ro \
    nginx:alpine

# Show running containers
echo "===== Running Containers ====="
docker ps

# Install curl if required
if ! command -v curl &> /dev/null
then
    dnf -y install curl
fi

# Check website
echo "===== Checking Website ====="
curl -I http://localhost

echo "===== Provisioning Completed ====="