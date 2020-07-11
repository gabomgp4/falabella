#!/usr/bin/env pwsh

#First step: configure azure cli credentials

properties {
    $suffix = "20201007"

    $registry_name = "ggomezregistry$suffix"
    $registry_domain = "$($registry_name).azurecr.io"
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

Task CreateResourceGroup -Depends InstallAzureCli {
    az group create --name $resourceGroup --location eastus
}

Task CreateDockerRegistry -Depends CreateResourceGroup {
    az acr create --resource-group $resourceGroup --name $registry_name --sku Basic
    sudo az acr login --name $registry_name
}

Task CreateAKSCluster -Depends CreateDockerRegistry, CreateResourceGroup {
    sudo az aks install-cli
    az aks create --resource-group $resourceGroup --name "$($resourceGroup)Cluster" `
        --node-count 2 --enable-addons monitoring --generate-ssh-keys `
        --attach-acr $registry_name
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

Task BuildDockerImage -Depends CreateDockerRegistry {
    pushd ./service
    sudo docker build . -t $registry_domain/falabella:$imageversion
    sudo docker push $registry_domain/falabella:$imageversion
    popd
}

Task DeployImage -Depends BuildDockerImage, CreateIngressController {
    helm install falabella ./helm/falabella --set ingress.hosts[0].host=$aksdomain `
        --set image.repository=$registry_domain/falabella `
        --set image.tag=$imageversion `
        --set service.type=ClusterIP `
        --set replicaCount=2
}

Task default -Depends DeployImage {

}