#! /bin/bash

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

sudo systemctl enable docker
sudo systemctl start docker

# Create app directory
sudo mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Create docker-compose.yml
sudo tee docker-compose.yml > /dev/null <<'COMPOSE_EOF'
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
    image: ${{ BACKEND_IMAGE }}
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
    image: ${{ FRONTEND_IMAGE }}
    container_name: frontend
    environment:
      - REACT_APP_BACKEND_URL=http://localhost:5000
    ports:
      - 3000:3000
    depends_on:
      - backend

volumes:
  mariadb_data:
COMPOSE_EOF

# Set proper ownership
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

