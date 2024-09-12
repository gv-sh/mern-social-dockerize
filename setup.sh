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
      sudo rm -rf mern-social-app
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

# Clean up existing Docker resources
clean_docker

# Clean up the previous project directory if it exists
clean_up

# Create a new directory for our project
mkdir -p mern-social-app
cd mern-social-app

# Clone the repository
git clone https://github.com/shamahoque/mern-social.git

# Sync contents to the current directory using rsync
rsync -av --progress mern-social/ . --exclude .git
rm -rf mern-social

# Ensure package.json exists in the client directory
if [ ! -f "client/package.json" ]; then
  if [ -f "package.json" ]; then
    cp package.json client/
    echo "Copied package.json to client directory"
  else
    echo "Error: package.json not found in the root or client directory. Please check the repository structure."
    exit 1
  fi
fi

# Verify client/package.json exists
if [ ! -f "client/package.json" ]; then
  echo "Error: client/package.json still not found after attempted copy. Please check the repository structure."
  exit 1
fi

# Create docker-compose.yml file
cat > docker-compose.yml << EOL
version: '3.8'

services:
  frontend:
    build:
      context: ./client
      dockerfile: Dockerfile
    container_name: mern-frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=https://localhost/api
    depends_on:
      - app
    volumes:
      - ./client:/usr/src/app
      - /usr/src/app/node_modules

  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: mern-app
    environment:
      - NODE_ENV=development
      - PORT=3000
      - JWT_SECRET=YOUR_secret_key
      - MONGODB_URI=mongodb://mongo:27017/mernproject
      - MONGO_HOST=mongo
      - MONGO_PORT=27017
    depends_on:
      - mongo
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    command: npm run development

  mongo:
    image: mongo:4.2.0
    container_name: mern-mongo
    volumes:
      - mongo-data:/data/db

  mongo-express:
    image: mongo-express
    container_name: mern-mongo-express
    environment:
      - ME_CONFIG_MONGODB_SERVER=mongo
      - ME_CONFIG_MONGODB_PORT=27017
    depends_on:
      - mongo

  nginx:
    image: nginx:alpine
    container_name: mern-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
      - frontend
      - mongo-express

networks:
  default:
    name: mern-network

volumes:
  mongo-data:
    driver: local
EOL

# Create Nginx configuration file
cat > nginx.conf << EOL
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server app:3000;
    }

    upstream mongo-express {
        server mongo-express:8081;
    }

    server {
        listen 80;
        server_name localhost;
        return 301 https://\$host\$request_uri;
    }

    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /api {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /mongo-express {
            proxy_pass http://mongo-express;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOL

# Generate self-signed SSL certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/localhost.key -out ssl/localhost.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

# Create Dockerfile for the backend
cat > Dockerfile << EOL
FROM node:13.12.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN mkdir -p node_modules && chown -R node:node .
USER node
RUN npm install
USER root
RUN npm install -g nodemon
USER node
RUN npm install @babel/plugin-transform-react-jsx --save-dev
COPY --chown=node:node . .
EXPOSE 3000
CMD ["npm", "run", "development"]
EOL

# Create Dockerfile for the frontend
cat > client/Dockerfile << EOL
FROM node:13.12.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm run build  # Ensure the build is run
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
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
echo "3. Access the application at https://localhost"
echo "4. Access Mongo Express at https://localhost/mongo-express"
echo ""
echo "If you still encounter permission issues, you can run Docker commands with sudo:"
echo "   sudo docker-compose build --no-cache"
echo "   sudo docker-compose up"