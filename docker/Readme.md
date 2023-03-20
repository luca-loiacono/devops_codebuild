**React Image Compressor Dockerization**

This is a simple bash script to dockerize the React Image Compressor application using Docker Compose.

**Requirements**

- Docker
- Docker Compose


**Usage**

Run the script:

``
sh dockerEnvironment.sh
``

Access the application on your browser: http://localhost:80

---

**What the script does**

The script checks if the directory react-image-compressor already exists. If it does, it outputs a message to the console indicating the repository already exists in the current directory. Otherwise, it clones the repository from GitHub and configures it.

It navigates to the react-image-compressor directory and creates a Dockerfile, a Docker Compose file, and an Nginx configuration file.

It builds and runs the service using docker-compose up --build -d.

Finally, it outputs a message to the console indicating that the application can be accessed on the browser at http://localhost:80.
