#!/usr/bin/env pwsh

#First step: configure azure cli credentials

properties {
    $registry = @{
        "server"= $null;
        "username"= $null;
        "password"= $null;
    }
    $aksdomain = "demo-aks-ingress"
    $external_ip = $null
    $imageversion = "0.1"
    $resourceGroup = "ggomez-aks-testing"
}

$registry_url = "$($registry.server).azurecr.io"

Task InstallDocker {
    apt-get update
    apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io
}

Task InstallHelm {
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}

Task InstallAzureCli {
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}


Task InstallBinaries -Depends InstallDocker,InstallHelm,InstallAzureCli {

}


Task CreateIngressController {
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

Task CreateAKSCluster -Depends InstallAzureCli {
    az group create --name $resourceGroup --location eastus
    az aks install-cli
    az aks create --resource-group $resourceGroup --name "$($resourceGroup)Cluster" --node-count 2 --enable-addons monitoring --generate-ssh-keys
    az aks get-credentials --resource-group $resourceGroup --name "$($resourceGroup)Cluster"
}

Task ConfigureDomainPublicIpAKS {
    # Public IP address of your ingress controller
    $IP="$external_ip"
    # Name to associate with public IP address
    $DNSNAME=$aksdomain
    # Get the resource-id of the public ip
    $PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)
    # Update public ip address with DNS name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
    # Display the FQDN
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv
    # Config regcred
    kubectl create secret docker-registry regcred --docker-server=$registry_url --docker-username=$($registry.username) --docker-password="$($registry.password)"
}


Task Build -depends BuildDockerImage {

}

Task DeployHelmChart {

}

Task BuildDockerImage {
    pushd ./service
    docker login $registry_url
    docker build . -t $registry_url/falabella:$imageversion
    docker push $registry_url/falabella:$imageversion
    popd
}