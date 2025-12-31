#! /usr/bin/bash

# export variables
export REGION="us-east-1"
export AWS_ACCOUNT_ID="289259597269"
export BACKEND_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/devops-backend:latest"
export FRONTEND_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/devops-frontend:latest"

sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker ubuntu
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app
touch compose.yml
touch deploy.sh

cat << EOF > compose.yml
version: '3'
services:
  devops_mariadb:
    image: mariadb
    container_name: db
    environment:
      - MARIADB_USER=test
      - MARIADB_PASSWORD=test
      - MARIADB_ROOT_PASSWORD=test
      - MARIADB_DATABASE=testdb
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s
    volumes:
      - mariadb_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin
    container_name: db-client
    ports:
      - 83:80
    environment:
      - PMA_HOST=devops_mariadb
      - PMA_USER=test
      - PMA_PASSWORD=test
    depends_on:
      devops_mariadb:
        condition: service_healthy

  backend:
    image: ${BACKEND_IMAGE}
    container_name: backend
    environment:
      - DB_USERNAME=test
      - DB_PASSWORD=test
      - DB_HOST=devops_mariadb
      - DB__NAME=testdb
    ports:
      - 5000:5000
    depends_on:
      devops_mariadb:
        condition: service_healthy

  frontend:
    image: ${FRONTEND_IMAGE}
    container_name: frontend
    environment:
      - REACT_APP_BACKEND_URL=http://localhost:5000
    ports:
      - 3000:3000
    depends_on:
      - backend

volumes:
  mariadb_data:
EOF

cat << EOF > deploy.sh
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker pull $FRONTEND_IMAGE
docker pull $BACKEND_IMAGE

docker compose down
docker compose up -d

EOF

chmod u+x deploy.sh