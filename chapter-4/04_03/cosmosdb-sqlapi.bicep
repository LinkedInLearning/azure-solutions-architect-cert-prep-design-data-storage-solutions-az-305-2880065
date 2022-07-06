@description('Static prefix for the cosmos DB account')
@minLength(3)
@maxLength(11)
param accountPrefix string

@description('Azure region where resources will be deployed, pulled from resourceGroup')
param location string = resourceGroup().location


var uniqueAccountName = '${accountPrefix}${uniqueString(resourceGroup().id)}'

resource cosmosdbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: uniqueAccountName
  location : location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-05-15' = {
  parent: cosmosdbAccount
  name: 'todoDemo'
  properties: {
    resource: {
        id: 'todoDemo'
    }
  }
}

resource Container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' = {
  parent: cosmosDatabase
  name: 'items'
  properties: {
    options: {
      throughput: 400
    }
    resource: {
      id: 'items'
      partitionKey: {
        paths: [
          '/itemId'
        ]
      }
    }
  }
}
