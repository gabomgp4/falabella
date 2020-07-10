import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure";
import * as k8s from "@pulumi/kubernetes";
import * as azuread from "@pulumi/azuread";
import * as config from "./config";

// Adapted from:
// https://www.pulumi.com/blog/create-aks-clusters-with-monitoring-and-logging-with-pulumi-azure-open-source-sdks/

// Create an Azure Resource Group
const resourceGroup = new azure.core.ResourceGroup(config.resourceGroupName);
export const loganalytics = new azure.operationalinsights.AnalyticsWorkspace("aksloganalytics", {
    resourceGroupName: resourceGroup.name,
    location: resourceGroup.location,
    sku: "PerGB2018",
    retentionInDays: 30,
})

// Step 2: Create the AD service principal for the k8s cluster.
let adApp = new azuread.Application("aks");
let adSp = new azuread.ServicePrincipal("aksSp", { applicationId: adApp.applicationId });
let adSpPassword = new azuread.ServicePrincipalPassword("aksSpPassword", {
    servicePrincipalId: adSp.id,
    value: config.password,
    endDate: "2099-01-01T00:00:00Z",
});

// Step 3: This step creates an AKS cluster.
export const k8sCluster = new azure.containerservice.KubernetesCluster("aksCluster", {
    resourceGroupName: resourceGroup.name,
    location: loganalytics.location,
    defaultNodePool: {
        name: "aksagentpool",
        nodeCount: config.nodeCount,
        vmSize: config.nodeSize,
    },
    dnsPrefix: `${pulumi.getStack()}-kube`,
    linuxProfile: {
        adminUsername: "aksuser",
        sshKey: { keyData: config.sshPublicKey, }
    },
    servicePrincipal: {
        clientId: adSp.applicationId,
        clientSecret: adSpPassword.value,
    },
    addonProfile: {
        omsAgent: {
            enabled: true,
            logAnalyticsWorkspaceId: loganalytics.id,
        },
    },
});

// Expose a k8s provider instance using our custom cluster instance.
export const k8sProvider = new k8s.Provider("aksK8s", {
    kubeconfig: k8sCluster.kubeConfigRaw,
});

// Export the kubeconfig
export const kubeconfig = k8sCluster.kubeConfigRaw
