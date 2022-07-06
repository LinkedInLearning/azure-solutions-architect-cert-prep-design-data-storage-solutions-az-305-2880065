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

@description('Tier')
@minLength(2)
param skuName string = 'S1'

@description('Allowed values for DTU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

var uniqueServerName = '${serverPrefix}${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

resource sqlserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: uniqueServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
  resource sqldb 'databases@2021-11-01-preview' = {
    name: 'dtudb'
    location: location
    sku: {
      name: skuName
      tier: skuTier
    }
  }
}
