#!/bin/bash

# Set up AWS CLI configuration (you may need to run this interactively)
aws configure

# Create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name MERN-App-SG --description "Security group for MERN application" --query 'GroupId' --output text)

echo "Created Security Group: $SECURITY_GROUP_ID"

# Frontend Inbound Rules
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0

# Backend Inbound Rules
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 3000 --cidr 0.0.0.0/0

# MongoDB Inbound Rule (restrict this to your backend's IP in production)
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 27017 --cidr 0.0.0.0/0

# Outbound Rules (allow all outbound traffic)
aws ec2 authorize-security-group-egress --group-id $SECURITY_GROUP_ID --protocol all --port all --cidr 0.0.0.0/0

echo "Security group rules have been set up."