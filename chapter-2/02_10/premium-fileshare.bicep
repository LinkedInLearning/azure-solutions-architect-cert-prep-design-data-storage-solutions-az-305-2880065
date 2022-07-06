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
param storageSKU string = 'Premium_LRS'

@description('Azure region where resources will be deployed, pulled from resourceGroup')
param location string = resourceGroup().location

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'FileStorage'
}

resource fService 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  name: 'default'
  parent: stg
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: 'premshare'
  parent: fService
  properties: {
    shareQuota: 100 //This is GB
    enabledProtocols: 'SMB'
  }
}

output storageEndpoint object = stg.properties.primaryEndpoints
