#!/bin/bash

# Check if exsist project react-image-compressor, else clone repo
if [[ -d ./react-image-compressor ]]
then
    echo "[INFO] Repository react-image-compressor.git already exsist in this Directory"
    sleep 1
else
    echo "[INFO] Repository react-image-compressor.git not exsist.. so i am cloning repo and configure it"
    git clone https://github.com/Rahul-Pandey7/react-image-compressor.git 
fi

# Navigate to the project directory
cd react-image-compressor

# Create a Dockerfile
cat <<EOF > Dockerfile
FROM node:12-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm", "start"]
EOF

# Create a Docker Compose file
cat <<EOF > docker-compose.yml
version: '3'
services:
  node:
    build: .
    ports:
      - "3000"
    networks:
      - my-network
  nginx:
    image: nginx:1.21.3-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    networks:
      - my-network
    depends_on:
      - node

networks:
  my-network:
EOF

# Create an Nginx configuration file
cat <<EOF > nginx.conf
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://node:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
}
EOF

# Build and run the service
docker-compose up --build -d


# Navigate on localhost:80
    echo "Check on you browser: http://localhost:80"
echo "\n"
