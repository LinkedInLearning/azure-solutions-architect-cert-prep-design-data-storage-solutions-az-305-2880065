@description('objectId for logged in user')
@secure()
param userObjectId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Admin username for authentication')
param adminUsername string

@description('Password for the admin username')
@minLength(12)
@secure()
param adminPassword string

@description('Static prefix for the server')
@minLength(3)
@maxLength(11)
param serverPrefix string

@description('Static prefix for the server')
@allowed([
  'GP_Gen5_2'
  'GP_Gen5_4'
  'GP_Gen5_4'
])
param skuName string = 'GP_Gen5_2'

param maxSizeBytes int = 10737418240

@description('Allowed values for vCore')
@allowed([
  'GeneralPurpose'
  'BusinessCritical'
])
param skuTier string = 'GeneralPurpose'

var uniqueServerName = '${serverPrefix}${uniqueString(resourceGroup().id)}'

@description('NAme for the Key Vault')
param uminame string = 'umisqlkvdb'

@description('Key size for the TDE protector')
@allowed([
  2038
  3072
])
param keyLength int = 3072

param kvName string = 'sqlkv-${uniqueString(resourceGroup().id)}'

// Create a keyvault, and use a nested resource to set a secret
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

// create user assigned managed identity
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: uminame
  location: location
}

// create role assignment
// GUIDs for Key Vault Administrator and Contributor, see the datae plan entry below:
// GUID for User Managed Identity is for Key Vault Crypt role - has Get, unwrapKey and wrapKey required for CMK
// see https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations
var KEY_VAULT_CRYPTO_ROLE_GUID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
var KEY_VAULT_ADMINISTRATOR = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','00482a5a-887f-4fb3-b363-3b7fe8e74483')
var KEY_VAULT_CONTRIBUTOR = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','f25e0fa2-a7c8-4377-a976-54943a77a395')

resource keyVaultSQLUser 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('tdekeyuser','az305sqldb')
  scope: keyVault
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: KEY_VAULT_CRYPTO_ROLE_GUID
  }
}

resource kvRoleAssignment1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, userObjectId, KEY_VAULT_CONTRIBUTOR)
  scope: keyVault
  properties: {
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: KEY_VAULT_CONTRIBUTOR
  }
}

resource kvRoleAssignment2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, userObjectId, KEY_VAULT_ADMINISTRATOR)
  scope: keyVault
  properties: {
    principalId: userObjectId
    roleDefinitionId: KEY_VAULT_ADMINISTRATOR
    principalType: 'User'
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  name: 'sqltdeprotector'
  parent: keyVault                
  properties: {
    kty: 'RSA'
    keySize: keyLength
  }
  dependsOn: [
    kvRoleAssignment2
    kvRoleAssignment1
  ]
}

resource sqlserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: uniqueServerName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    keyId: key.properties.keyUriWithVersion
    primaryUserAssignedIdentityId : uami.id
  }
  resource sqldb 'databases@2021-11-01-preview' = {
    name: 'vcoredb'
    location: location
    sku: {
      name: skuName
      tier: skuTier
    }
    properties: {
      maxSizeBytes: maxSizeBytes
    }
  }
}
