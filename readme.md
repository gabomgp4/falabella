# Technical test for Devops Engineer

In this project you can see one possible way to solve the proposed test. I'm using Powershell only to allow me to use a simple library named psake, that is similar in nature to make or rake. In work, I'm used to Pulumi,so normally I'm no putting so much logic in bash or some scripting language to do automation. I write almost all automation logic using resources in Pulumi, in its native way.

# Script Instructions

The present script uses bash and PowerShell to offer a way to build and deploy the service and install requirements.

## Requirements

To get the better experience with this instructions you might have a Azure Account, so the steps can be fully automated. It's possible to open a azure account with free credits following the instructions in [this page](https://azure.microsoft.com/en-us/free/)

## Clone the source code

You must clone the git repository with the source code using the following instruction:

```bash
git clone https://github.com/gabomgp4/falabella.git
```

You must have configured the credentials to allow git to clone the repository.

## Powershell and psake

For a easy experience, the script is written in porwershell and psake. Powershell is a alternative shell very common in Microsoft's ecosystem, it's main feature is to be a object oriented shell. More information about powershell can be obtained in (What is Powershell)[https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7] in the official documentation site.

The library psake is a build engine written in powershell, so the same language used to run the automatization can be used to coordinate the taks. The psake tool is similiar to rake or make, It allows to write a DAG (Directec Acyclical Graph) of tasks expressing its dependencies.

So, to install powershell and psake, please run the command:

```bash
cd falabella
sh install_powershell.sh
```

It is posible that the script requests you for the root credential to do some package installation, please provide it.

Also, the script could requests you to change the InstallationPolicy for powershell to allow the installation of psake with the following message:

    You are installing the modules from an untrusted repository. If you trust this repository, change its InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from 'PSGallery'?


Please allow to change the InstallationPolicy configuration writting Y in the keyboard.

## Azure CLI installed and configured

This readme and the script are optimized to use AKS as the Kubernetes cloud service, so for a straigtforward experience is recommended to install the Azure CLI with the command:

```powershell

```

Please note that the powershell snippets requires you to enter the PowerShell shell with the command:

```bash
pwsh
```

## Azure CLI

You should install and configure Azure CLI. To do that, execute the following command:

```bash
cd falabella

```

## Docker image registry

You will need a docker image registry created and its credentials to allow push te builded images and pulling from kubernetes cluster. I'll offer you two options for this.

### Manual image registry creation

You can use whatever image registry provider you want. The important thing for this exercise is to configure the docker credentials in the building machine to access that registry. For example, to create the registry you can follow in the Azure Portal [this steps](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal) and to configure the docker credential you can follow [this instructions](https://stackoverflow.com/a/58956760/13071418)

### Automatic image registry creation

Here is the recommended way to create the image registry in Azure and configure the docker cli to connect to that registry:


## Kubernetes cluster

You will need a Kubernetes cluster created and the kubectl command line tool configured to allow acces the cluster and deploy to it.

A very easy way to get a new configured Kubernetes cluter and the kubectl command line tool configured is to use the task *CreateAKSCluster* with the command:

```powershell

```

For information about createing a AKS Cluster, you can see the [official documentation](
