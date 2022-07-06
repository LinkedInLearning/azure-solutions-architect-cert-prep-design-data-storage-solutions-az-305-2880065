@description('Admin username for authentication')
param adminUsername string

@description('Password for the admin username')
@minLength(12)
@secure()
param adminPassword string

@description('Static prefix for the storage account')
@minLength(3)
@maxLength(11)
param dbPrefix string

var uniqueDBName = '${dbPrefix}${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

resource sqldb 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: uniqueDBName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}
