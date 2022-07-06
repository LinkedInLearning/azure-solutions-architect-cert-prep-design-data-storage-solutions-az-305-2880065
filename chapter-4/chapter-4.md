# Chapter 4 - Azure Coosmosdb and Azure Tables

## 04_01 Azure Table & Azure Cosmos Intro

Setup the storage account

    az account set --subscription <subscriptionid>

    az group create --name rg-table --location eastasia

    az deployment group create --resource-group rg-table --template-file standard.bicep --parameters storageSKU=Standard_LRS 

Add the table manually through the portal, then add entities through the storage browser

Add the Cosmos DB account manually through the portal.


## 04_03 Cosmos DB - Consistency level

Setup to alter the consistency level manually for a SQL API account

    az account set --subscription <subscriptionid>

    az group create --name rg-cons-level --location eastasia

Pass in a consistency level to set up the consistency policy

    az deployment group create --resource-group rg-cons-level --template-file cosmosdb-sqlapi-level.bicep --parameters defaultConsistencyLevel=BoundedStaleness


## 04_03 Cosmos DB - Capacity and indexing (RUs)

This demo uses the dotnet cosmicworks tool - https://www.nuget.org/packages/CosmicWorks/

    az account set --subscription <subscriptionid>

    az group create --name rg-capacity --location eastasia

Setup an account with account name of cosmicworks, database of products and partition key of productID

    az deployment group create --resource-group rg-capacity --template-file cosmosdb-sqlapi-cosmic.bicep

Copy the endpoint and write key from the created Cosmos DB

Use the cosmic works tool to pupulate the cosmicworks sample database

    dotnet tool install --global CosmicWorks --version 1.0.7

    cosmicworks --endpoint <cosmos-endpoint> --key <cosmos-key> --datasets product