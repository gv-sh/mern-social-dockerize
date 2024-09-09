#!/bin/bash

# Clone the repository
git clone https://github.com/shamahoque/mern-social.git
cd mern-social

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

docker-compose up --build