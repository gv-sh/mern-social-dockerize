# MERN Social Application Setup

This repository contains a setup script and Docker configuration for running the MERN Social application.

## Prerequisites

Before running the setup script, ensure you have the following installed on your system:
- Git
- Docker
- Docker Compose
- AWS CLI (if you plan to use AWS services)

## Setup Instructions

1. Clone this repository:
   ```
   git clone https://github.com/gv-sh/mern-social-dockerize.git
   cd mern-social-dockerize
   ```

2. Make the setup script executable:
   ```
   chmod +x setup.sh install-packages.sh configure-security-group.sh
   ```

3. Run the setup script:
   ```
   ./setup.sh
   ```

   This script will:
   - Clone the MERN Social repository
   - Create a `docker-compose.yml` file
   - Create a `Dockerfile`
   - Build and run the Docker containers

4. Once the script completes, the application should be running. Access it at:
   ```
   http://localhost:3000
   ```

## Manual Setup (if needed)

If you prefer to set up the application manually:

1. Clone the MERN Social repository:
   ```
   git clone https://github.com/shamahoque/mern-social.git
   cd mern-social
   ```

2. Create the `docker-compose.yml` and `Dockerfile` as specified in the `setup.sh` script.

3. Build and run the Docker containers:
   ```
   docker-compose up --build
   ```

## Troubleshooting

If you encounter any issues:
- Ensure Docker and Docker Compose are properly installed and running.
- Check if the required ports (3000 for the app, 27017 for MongoDB) are available.
- Review the console output for any error messages.

## Contributing

Feel free to submit issues or pull requests if you have suggestions for improvements or encounter any problems.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.