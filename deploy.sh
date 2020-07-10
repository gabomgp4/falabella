
# Docker is installed in the building machine

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Helm is installed in the building machine

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

#paramétros
registry=ggomezakstesting.azurecr.io


# The  service docker image is builded

pushd ./service
docker login $registry
docker build . -t $registry/falabella:0.1
docker push $registry/falabella:0.1
popd

# Install nginx ingress controller

# Create a namespace for your ingress resources
kubectl create namespace ingress-basic
# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

#TODO: Explicar que se debe haber configurado las
# * credenciales del registro docker
# *
