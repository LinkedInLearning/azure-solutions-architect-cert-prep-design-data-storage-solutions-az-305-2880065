@description('Static prefix for the storage account')
@minLength(3)
@maxLength(11)
param storagePrefix string

@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow()

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

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  properties: {
    allowBlobPublicAccess: true
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' = {
    name: 'default'

    resource firstContainer 'containers' = {
      name: 'text'
      properties: {
        publicAccess : 'Container'
      }
    }
    resource secondContainer 'containers' = {
      name: 'json'
      properties: {
        publicAccess : 'Container'
      }
    }
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: stg.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: stg.listKeys().keys[0].value
      }
      {
        name: 'TXTCONTENT'
        value: loadTextContent('../data/blob.txt')
      }
      {
        name: 'JSONCONTENT'
        value: loadTextContent('../data/blob.json')
      }
    ]
    scriptContent: '''
                        echo "$TXTCONTENT" > blob.txt
                        echo "$JSONCONTENT" > blob.json

                        az config set extension.use_dynamic_install=yes_without_prompt
                        az extension add -n storage-blob-preview

                        az storage blob upload --file blob.txt --container-name text --name blob.txt --tags "project=beta" --overwrite

                        az storage blob upload --file blob.txt --container-name text --name blob-2.txt --tags "project=gamma" --overwrite

                        az storage blob upload --file blob.json --container-name json --name blob.json --tags "project=beta" --overwrite

                        az storage blob upload --file blob.json --container-name json --name blob-2.json --tags "project=gamma" --overwrite
                  '''
  }
}

output storageEndpoint object = stg.properties.primaryEndpoints
