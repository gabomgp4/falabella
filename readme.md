# Technical test for DevOps Engineer

In this project, you can see one possible way to solve the proposed test. I'm using Powershell only to allow me to use a simple library named psake, which is similar to make or rake tools. In work, I'm used to Pulumi, so normally I'm no putting so much logic in bash or some scripting language to do automation. I write almost all automation logic using resources in Pulumi, in its native way.

# Script Instructions

The present script uses bash and PowerShell to offer a way to build and deploy the service and install requirements.

## Requirements

To get a better experience with these instructions you might have an Azure Account, so the steps can be fully automated. It's possible to open an Azure account with free credits following the instructions in [this page](https://azure.microsoft.com/en-us/free/)

## Clone the source code

You must clone the git repository with the source code using the following instruction:

```bash
git clone https://github.com/gabomgp4/falabella.git
```

You must have configured the credentials to allow git to clone the repository.

## Powershell and psake

For an easy experience, the script is written in Powershell and psake. Powershell is an alternative shell very common in Microsoft's ecosystem, it's the main feature is to be an object-oriented shell. More information about PowerShell can be obtained in (What is Powershell)[https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7] in the official documentation site.

The library psake is a build-engine written in PowerShell, so the same language used to run the automatization can be used to coordinate the tasks. The psake tool is similar to rake or make, It allows us to write a DAG (Directed Acyclical Graph) of tasks expressing its dependencies.

So, to install PowerShell and psake, please run the command:

```bash
cd falabella
sh install_powershell.sh
```

It is possible that the script requests you for the root credential to do some package installation, please provide it.

Also, the script could request you to change the InstallationPolicy for PowerShell to allow the installation of psake with the following message:

    You are installing the modules from an untrusted repository. If you trust this repository, change its InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from 'PSGallery'?


Please allow to change the InstallationPolicy configuration writing Y in the keyboard.

## Azure CLI installed and configured
This readme and the script are optimized to use AKS as the Kubernetes cloud service. The next steps are inside a PowerShell shell that can be opened with:

```bash
pwsh
```

So, in the PowerShell shell you can enter the next command to install the necessary binary dependencies to follow the readme:

```powershell
Invoke-psake build.ps1 InstallBinaries
```

## Azure CLI

It's better to connect the Azure CLI to your account. To do that, execute the following command:

```powershell
az login
```

The command request you to enter an authentication code in a specific URL in the browser, please do that and enter the provided code.

## Docker image registry

The recommended way to create the image registry in Azure and configure the docker CLI to connect to that registry is with the following command:

```powershell
Invoke-psake build.ps1 CreateDockerRegistry
```

## Kubernetes cluster


A very easy way to get a new configured Kubernetes cluster and the kubectl command-line tool configured is to use the task *CreateAKSCluster* with the command:

```powershell
Invoke-psake build.ps1 CreateAKSCluster
```

It is recommended to use the task *CreateIngressController* to allow AKS Cluster to support ingress resources:

```powershell
Invoke-psake build.ps1 CreateIngressController
```

## Docker image building

To build the docker image, you can use the command:

```
Invoke-psake build.ps1  BuildDockerImage
```

Take into account that the unit tests are executed as part of the docker image building, as a phase in the multi-phase dockerfile. That can be changed, but for me is preferable to block the image building process if something as important as the unit tests are failing. For python, I cant see to much value in having a separate phase at the psake level, although that can be made.

## Final deploying

The command to do the final deploying from the docker registry to the AKS cluster is to:

```powershell
Invoke-psake build.ps1  DeployImage
```

Or if you want, it's possible to omit the task name with:

```powershell
Invoke-psake build.ps1
```

The result from the two commands is the same, but if you want to use the second one, you must configure the Azure CLI credentials before.

# Final observations

To put the service in a real production environment, I can see the next things are missing:

* To develop E2E tests that are executed as after the deployment, automatically, using docker. I prefer to use selenium from Typescript to do the tests, but I hadn't enough time to do that thing.
* I'm very happy using Pulumi, and in this very simple case is not necessary, but to orchestrate many resources, including resources that are from different cloud providers, It's a very effective tool, similar to Terraform but better for me.
* In a real service, probably we want to do proper integration testing too, coordinating two or more docker containers to the integration testing.
* It's missing some piece to do the GitOps, I used TFS pipelines as the process triggers that start new work in response to pushed commits in the git repository (TFS too).