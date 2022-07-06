# Chapter 2 - Azure Storage

## 02_02 Create a Standard LRS account

    az account set --subscription <subscriptionid>

    az group create --name rg-storage --location ukwest

    az deployment group create --resource-group rg-storage --template-file standard.bicep --parameters storageSKU=Standard_LRS

## 02_02 Create a Standard ZRS account

Don't forget to choose a region where there are availability zones!

    az account set --subscription <subscriptionid>

    az group create --name rg-storage --location uksouth

    az deployment group create --resource-group rg-storage --template-file standard.bicep --parameters storageSKU=Standard_ZRS

## 02_02 Create a Standard GRS account

    az account set --subscription <subscriptionid>

    az group create --name rg-storage --location uksouth

    az deployment group create --resource-group rg-storage --template-file standard.bicep --parameters storageSKU=Standard_GRS

## 02_02 List the files in the primary container (public access)

This is the bicep file from the geo-redundancy demo

    az account set --subscription <subscriptionid>

    az group create --name rg-ragrs --location northeurope

    az deployment group create --resource-group rg-ragrs --template-file standard-ragrs-secondary.bicep

Use a browser to list the primary container

    https://<storageaccountname>.blob.core.windows.net/data?restype=container&comp=list


Use a browser to show the file contents

    https://<storageaccountname>.blob.core.windows.net/data/blob.txt

Use a browser to show the file contents from the secondary

    https://<storageaccountname>-secondary.blob.core.windows.net/data/blob.txt

Use Azure CLI to checkout the last synch time

    az storage account show \
        --name <storage-account> \
        --resource-group rg-ragrs \
        --expand geoReplicationStats \
        --query geoReplicationStats.lastSyncTime \
        --output tsv

Use Azure CLI to list from a file share
    
    az storage file list --account-name <accountname> --name <filesharename>

    az storage file list --account-name <accountname> --name <filesharename> --account-key <accountKey>

Use Azure CLI to delete a file share
    
    az storage share delete --account-name <accountname> --name <filesharename> --account-key <accountKey>

List a container - requires the SAS key to be added on
    
    https://<accountname>.blob.core.windows.net/<containername>?restype=container&comp=list


## 02_03 Create a bicep template that links a VM to storage using managed identity?

## 02_04 Public & Private Networking

In the cloudshell create a storage account with Standard_LRS, with anonymous public access to a blob in the storage account enabled and public network access.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-networking-sa --location <location>

    az deployment group create --resource-group rg-networking-sa --template-file standard.bicep --parameters storageSKU=Standard_LRS


Explore public network access and switching to Firewall rules with an IP and adding your client IP.

Create two vms in seperate subnets in the same vnet with RDP access through nsgs on the subnets and public IPs

Note this uses a VNet of 10.0.0.0/16, if this is already being used, you'll need to change the underlying scripts

    az deployment group create --resource-group rg-networking-sa --template-file vms-service-endpoint.bicep --parameters adminUsername=superuser

## 02_05 Customer-managed keys

    az account set --subscription <subscriptionid>
    
    az group create --name rg-encrypt-sa --location <location>

    az deployment group create --resource-group rg-encrypt-sa --template-file standard-encrypt-options.bicep --parameters storageSKU=Standard_LRS

To enable CMK encryption for Tables and queues

    az deployment group create --resource-group rg-encrypt-sa --template-file standard-encrypt-options.bicep --parameters storageSKU=Standard_LRS enableEncryptedQueues=true enableEncryptedTables=true

Create the keyvault

Get your users objectId

    az ad signed-in-user show --query objectId -o tsv

    az deployment group create --resource-group rg-encrypt-sa --template-file keyvault.bicep


## 02_06 Access tiers

    az account set --subscription <subscriptionid>
    
    az group create --name rg-accesstier-sa --location <location>

Create with a default access tier of hot

    az deployment group create --resource-group rg-accesstier-sa --template-file standard-tier-options.bicep --parameters storageSKU=Standard_LRS accessTier=Hot

Or a default access tier of cool

    az deployment group create --resource-group rg-accesstier-sa --template-file standard-tier-options.bicep --parameters storageSKU=Standard_LRS accessTier=Cool


## 02_07 Lifecycle management

Setup the storage account with two containers and two tagged blobs each

    az account set --subscription <subscriptionid>
    
    az group create --name rg-lifecycle-sa --location <location>

    az deployment group create --resource-group rg-lifecycle-sa --template-file standard-multi-blob.bicep --parameters storageSKU=Standard_LRS

Hitting the find blobs with tags endpoint requires authorization, so tag a SAS Token with list, and blob index permissions at the service level

    https://<accountname>.blob.core.windows.net/?comp=blobs&where=Project%3D%20%27Apollo&<SAS Token>


## 02_08 Protecting blobs

Setup the storage account with soft delete for containers and blobs turned on along with blob versioning. Add two containers and two blobs.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-protect-sa --location <location>

    az deployment group create --resource-group rg-protect-sa --template-file standard-blob-protection.bicep --parameters storageSKU=Standard_LRS


## 02_09 Immutable Storage Account

Setup the storage account with soft delete for containers and blobs turned on along with blob versioning. Add two containers and two blobs.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-immutable-sa --location <location>

Add a storage account with version-level immutability set at the storage account

If you run this two containers and two blobs in each will be added. To delete them you will need to remove the access policy at the storage account and then at the blob level, and then delete the blobs and then the containers and then the account.

    az deployment group create --resource-group rg-immutable-sa --template-file standard-blob-immutable-version-level.bicep --parameters storageSKU=Standard_LRS

Add a storage account with no immutability set at the storage account

    az deployment group create --resource-group rg-immutable-sa --template-file standard-blob-immutable-notset.bicep --parameters storageSKU=Standard_LRS


## 02_10 File shares

Create a standard and non standard file share

    az account set --subscription <subscriptionid>
    
    az group create --name rg-fileshare-sa --location <location>

Standard hot tier fileshare

    az deployment group create --resource-group rg-fileshare-sa --template-file standard-fileshare-hot.bicep

Premium fileshare 2GB quota

    az deployment group create --resource-group rg-fileshare-sa --template-file premium-fileshare.bicep