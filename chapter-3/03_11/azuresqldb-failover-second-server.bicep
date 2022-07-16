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

var uniqueServerName = '${serverPrefix}${uniqueString(resourceGroup().id)}'

@description('Location for all primary resources.')
param primaryLocation string = resourceGroup().location

resource sqlserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: uniqueServerName
  location: primaryLocation
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}
