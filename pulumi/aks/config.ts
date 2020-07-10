import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
export const password = config.require("password");
export const location = config.get("location") ?? "East US";
export const failoverLocation = config.get("failoverLocation") ?? "East US 2";
export const nodeCount = config.getNumber("nodeCount") ?? 2;
export const nodeSize = config.get("nodeSize") ?? "Standard_D2_v2";
export const sshPublicKey = config.require("sshPublicKey");
export const resourceGroupName = config.get("resourceGroupName") ?? "aks-falabella";