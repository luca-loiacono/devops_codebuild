#!/bin/sh

### var
KIND_CLUSTER_NAME="kind"
checkmark="\xE2\x9C\x93"

if [[ -d ./react-image-compressor ]]

        then
            echo "[INFO] Repository react-image-compressor.git already exsist in this Directory"
            sleep 1

        else
            echo "[INFO] Repository react-image-compressor.git not exsist.. so i am cloning repo and configure it"
            # Clone repository react-image-compressor
            git clone https://github.com/Rahul-Pandey7/react-image-compressor.git 
            # Navigate to the project directory
            #cd react-image-compressor ;

            # Create a Dockerfile
            #cat <<EOF > Dockerfile
            #FROM node:12-alpine

            #WORKDIR /app

            #COPY package*.json ./

            #RUN npm install

            #COPY . .

            #CMD ["npm", "start"]
            #EOF

fi

# Create a Dockerfile
cat <<EOF > react-image-compressor/Dockerfile
FROM node:12-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
EOF

# Check if exsist kind cluster
if [[ $(kind get clusters | grep $KIND_CLUSTER_NAME) == $KIND_CLUSTER_NAME ]]; then

    echo "[WARN] Cluster "kind" already exsist. You have to delete it, so you can and restart the script"
    echo "[INFO] You can use the following command: kind delete clusters kind"
    exit 1;

  else

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5001'
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
   echo "Creating local docker registry. Will be ready on localhost:5001"
   docker run -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:5000"]
EOF

# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  docker network connect "kind" "${reg_name}"
fi

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
echo "\n"

fi

# Setup kubectl to kind cluster
kubectl cluster-info --context kind-kind

# Check if control-plane is ready
echo "\n"
echo "Control Plane is not ready, waiting..."

KIND_CLUSTER_STATUS=$(kubectl get node | grep "control-plane" | awk '{print $2}')
while [[ $KIND_CLUSTER_STATUS != "Ready" ]]; do
  KIND_CLUSTER_STATUS=$(kubectl get node | grep "control-plane" | awk '{print $2}')
  if [[ $KIND_CLUSTER_STATUS == "Ready" ]]; then
    echo -e "$checkmark Control Plane is ready!"
  else
    echo "waiting..."
    sleep 5
  fi
done

echo "\n"

# Create directory for k8s resources
mkdir -p react-image-compressor/k8s/

# Docker command to build, tag and push react-image-compressor
echo "\n" 
echo "Build, tag and push react-image-compressor on local registry --> localhost:5001" 
cd react-image-compressor
docker build -t react-image-compressor .
docker tag react-image-compressor localhost:5001/react-image-compressor:0.0.1
docker push localhost:5001/react-image-compressor:0.0.1
cd ../
echo "\n"


# Create deployment + service react-image-compressor.yaml
cat <<EOF > react-image-compressor/k8s/react-image-compressor.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-image-compressor
spec:
  selector:
    matchLabels:
      app: react-image-compressor
  replicas: 1
  template:
    metadata:
      labels:
        app: react-image-compressor
    spec:
      containers:
        - name: nginx
          image: nginx:1.21.3-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config

---
apiVersion: v1
kind: Service
metadata:
  name: react-image-compressor
spec:
  selector:
    app: react-image-compressor
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# Create deployment + service - react-image-compressor-be.yaml
cat <<EOF > react-image-compressor/k8s/react-image-compressor-be.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-image-compressor-be
spec:
  selector:
    matchLabels:
      app: react-image-compressor-be
  replicas: 1
  template:
    metadata:
      labels:
        app: react-image-compressor-be
    spec:
      containers:
        - name: web
          image: localhost:5001/react-image-compressor:0.0.1
          ports:
            - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: react-image-compressor-be
spec:
  selector:
    app: react-image-compressor-be
  ports:
    - name: tcp
      port: 3000
      targetPort: 3000
  type: ClusterIP
EOF

# Create nginx configmap that will be mount on react-image-compressor deployment
cat <<\EOF > react-image-compressor/k8s/react-image-compressor-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://react-image-compressor-be:3000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            access_log /var/log/nginx/access.log;
            error_log /var/log/nginx/error.log;
        }
    }
EOF

# Apply k8s resources on kind cluster
echo "Apply kubernetes resources:"
kubectl apply -f react-image-compressor/k8s/
echo "\n"

# Check pods running
    echo "Check if pods are running with command --> kubectl get pod -A -o wide"
    echo "\n"

# Expose react-image-compressor on localhost:8080
    echo "Expose react-image-compressor on localhost:8080 --> kubectl port-forward svc/react-image-compressor 8080:80 & and check on you browser: http://localhost:8080"
echo "\n"


# Cleanup environment
echo "Cleanup with the following command:"
echo "> kind delete clusters kind"
echo "> docker stop kind-registry"
echo "> docker rm kind-registry"
echo "> rm -fr react-image-compressor/"
