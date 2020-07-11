#!/usr/bin/env pwsh

#First step: configure azure cli credentials

properties {
    $suffix = "20201007"


    $registry_server = "ggomez-test-$suffix"
    $registry_url = "$($registry_server).azurecr.io"
    $aksdomain = "demo-aks-ingress-$suffix"
    $imageversion = "0.1"
    $resourceGroup = "ggomez-aks-testing-$suffix"
}

Task InstallDocker {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
}

Task InstallHelm {
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}

Task InstallAzureCli {
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}


Task InstallBinaries -Depends InstallDocker, InstallHelm, InstallAzureCli {
    "install binaries"
}

Task CreateResourceGroup {
    az group create --name $resourceGroup --location eastus
}

Task CreateDockerRegistry -Depends CreateResourceGroup {
    az acr create --resource-group $resourceGroup --name ggomezregistry$suffix --sku Basic
    sudo az acr login --name ggomezregistry$suffix
}

Task CreateAKSCluster -Depends InstallAzureCli, CreateResourceGroup {
    sudo az aks install-cli
    az aks create --resource-group $resourceGroup --name "$($resourceGroup)Cluster" --node-count 2 --enable-addons monitoring --generate-ssh-keys
    sudo az aks get-credentials --resource-group $resourceGroup --name "$($resourceGroup)Cluster"
}

Task ConfigureDomainPublicIpAKS -Depends CreateAKSCluster {
    $rgKubernetesResources = "MC_$resourceGroup_$($resourceGroup)Cluster_eastus"
    $PUBLICIPID=$(az network public-ip list --resource-group=$rgKubernetesResources --query "[?tags.owner!=null]|[?contains(tags.owner, 'kubernetes')].[id]" --output tsv)
    $DNSNAME=$aksdomain
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv
}

Task CreateIngressController -Depends ConfigureDomainPublicIpAKS, InstallHelm {
    # # Install nginx ingress controller, necesary in AKS
    # Create a namespace for your ingress resources
    kubectl create namespace ingress-basic
    # Add the official stable repository
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/

    # Use Helm to deploy an NGINX ingress controller
    helm install nginx-ingress stable/nginx-ingress `
        --namespace ingress-basic `
        --set controller.replicaCount=2 `
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
}

Task CreateRegcred {
    pushd ~
    sudo cat ~/.docker/config.json > ~/.dockerconfig.json
    kubectl create secret generic regcred `
        --from-file=.dockerconfigjson=.dockerconfig.json `
        --type=kubernetes.io/dockerconfigjson
    popd
}

Task BuildDockerImage, CreateDockerRegistry {
    pushd ./service
    sudo docker build . -t $registry_url/falabella:$imageversion
    sudo docker push $registry_url/falabella:$imageversion
    popd
}

Task DeployImage -Depends CreateRegcred, BuildDockerImage {

}