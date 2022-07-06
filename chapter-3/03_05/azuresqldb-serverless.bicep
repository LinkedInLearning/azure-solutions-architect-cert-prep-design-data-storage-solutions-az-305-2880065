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

@description('Enter a value for the serverless SKU')
@allowed([
  'GP_S_Gen5_2'
  'GP_S_Gen5_4'
  'GP_S_Gen5_6'
])
param skuName string = 'GP_S_Gen5_2'

param maxSizeBytes int = 10737418240

@description('Allowed values for vCore')
@allowed([
  'GeneralPurpose'
  'BusinessCritical'
])
param skuTier string = 'GeneralPurpose'

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
