@description('objectId for logged in user')
@secure()
param userObjectId string

@description('Name for the keyvault')
param kvname string = 'kvsa305encrypt'

@description('Azure region where resources will be deployed, pulled from resourceGroup')
param location string = resourceGroup().location

resource kv 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: kvname
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: userObjectId
        permissions: {
          keys: [
            'create'
            'list'
            'delete'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
}
