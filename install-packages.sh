#!/bin/bash

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
check_command "Installing prerequisites"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
check_command "Adding Docker GPG key"

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
check_command "Adding Docker repository"

sudo apt-get update
sudo apt-get install -y docker-ce
check_command "Installing Docker"

sudo systemctl start docker
sudo systemctl enable docker
check_command "Starting Docker service"

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
check_command "Installing Docker Compose"

# Verify Docker and Docker Compose installations
docker --version
docker-compose --version
