**React Image Compressor - Kubernetes Resources**

This script clones the react-image-compressor repository, creates a Docker image for it, and deploys it on a Kubernetes cluster created using Kind.

**Prerequisites**

To run this script, you need the following tools installed on your system:

- Docker
- go1.16 or greater

**Usage**

Run the script:

``sh kubernetesEnvironment.sh``

--- 
**Script Steps**

Check if the react-image-compressor repository is already cloned in the current directory. If it is not, then the script clones it from GitHub.
Create a Dockerfile for react-image-compressor and build a Docker image.

Check if a Kind cluster named kind already exists. If it does, then the script exits. Otherwise, the script creates a new Kind cluster with a local Docker registry enabled.
Wait for the Kind cluster control plane to become ready.

Build a Docker image for react-image-compressor, tag it, and push it to the local registry.
Create a deployment and a service for react-image-compressor on the Kind cluster.

**Note**

If you encounter any issues with the script, please try deleting the Kind cluster using the following command and then run the script again:

``kind delete clusters kind``

---
**Cleanup environment**


Cleanup with the following command:

- ``kind delete clusters kind``
- ``docker stop kind-registry``
- ``docker rm kind-registry``
- ``rm -fr ./react-image-compressor``

