#!/bin/bash

# Create a new directory for our project
mkdir -p mern-social-app
cd mern-social-app

# Clone the repository
git clone https://github.com/shamahoque/mern-social.git
mv mern-social/* .
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
    volumes:
      - .:/usr/src/app
    environment:
      - MONGO_URL=mongodb://mongo:27017/mern-social
    depends_on:
      - mongo
    command: npm run development

  mongo:
    image: mongo:4.2.0
    container_name: mern-mongo
    ports:
      - "27017:27017"
    volumes:
      - ./data:/data/db
EOL

# Create Dockerfile
cat > Dockerfile << EOL
FROM node:13.12.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
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