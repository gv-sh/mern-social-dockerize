#!/bin/bash

# Function to check if Docker is installed
check_docker() {
  if ! [ -x "$(command -v docker)" ]; then
    echo "Error: Docker is not installed." >&2
    exit 1
  fi
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo "Error: Docker Compose is not installed." >&2
    exit 1
  fi
}

# Function to clean up previous project directory if it exists
clean_up() {
  if [ -d "mern-social-app" ]; then
    read -p "Directory 'mern-social-app' already exists. Do you want to remove it and start fresh? (y/n) " choice
    if [ "$choice" = "y" ]; then
      rm -rf mern-social-app
      echo "Previous 'mern-social-app' directory removed."
    else
      echo "Exiting script to avoid overwriting existing files."
      exit 1
    fi
  fi
}

# Function to remove existing Docker containers, images, and volumes
clean_docker() {
  docker-compose down -v --rmi all 2>/dev/null
  docker system prune -f
  echo "Cleaned up existing Docker containers, images, and volumes."
}

# Check if Docker and Docker Compose are installed
check_docker

# Clean up the previous project directory if it exists
clean_up

# Clean up existing Docker resources
clean_docker

# Create a new directory for our project
mkdir -p mern-social-app
cd mern-social-app

# Clone the repository
git clone https://github.com/shamahoque/mern-social.git

# Sync contents to the current directory using rsync
rsync -av --progress mern-social/ . --exclude .git
rm -rf mern-social

# Create docker-compose.yml file
cat > docker-compose.yml << EOL
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: mern-app
    ports:
      - "3000:3000" # Exposing backend port
    environment:
      - MONGO_URL=mongodb://mongo:27017/mern-social
    depends_on:
      - mongo
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    command: npm run development

  mongo:
    image: mongo:4.2.0
    container_name: mern-mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:
    driver: local
EOL

# Create Dockerfile
cat > Dockerfile << EOL
FROM node:13.12.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install -g nodemon
COPY . .
EXPOSE 3000
CMD ["npm", "run", "development"]
EOL

# Add current user to the docker group
sudo usermod -aG docker $USER

# Change ownership of the current directory to the current user
sudo chown -R $USER:$USER .

# Make sure the current user can read and write to the docker socket
sudo chmod 666 /var/run/docker.sock

# Inform the user about the next steps
echo "Setup complete. Please follow these steps:"
echo "1. Log out and log back in for the group changes to take effect."
echo "2. After logging back in, run the following commands:"
echo "   cd mern-social-app"
echo "   docker-compose build --no-cache"
echo "   docker-compose up"
echo ""
echo "If you still encounter permission issues, you can run Docker commands with sudo:"
echo "   sudo docker-compose build --no-cache"
echo "   sudo docker-compose up"