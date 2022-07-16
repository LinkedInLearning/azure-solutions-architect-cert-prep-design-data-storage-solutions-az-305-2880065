@description('Static prefix for the storage account')
@minLength(3)
@maxLength(11)
param storagePrefix string

@description('Allowed values for storageSKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

@description('Azure region where resources will be deployed, pulled from resourceGroup')
param location string = resourceGroup().location

@description('CHoose a region outside of the resource group')
param secondLocation string

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

var uniqueStorageNameLocn2 = '${secondLocation}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
}

resource stglocn2 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageNameLocn2
  location: secondLocation
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
}

output storageEndpoint object = stg.properties.primaryEndpoints
