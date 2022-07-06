@description('Static prefix for the cosmos DB account')
@minLength(3)
@maxLength(11)
param accountPrefix string

@description('Azure region where resources will be deployed, pulled from resourceGroup')
param location string = resourceGroup().location

@description('The default consistency level of the Cosmos DB account.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Session'

var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}

@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000.')
@minValue(10)
@maxValue(2147483647)
param maxStalenessPrefix int = 100000

@description('Max lag time (minutes). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300


var uniqueAccountName = '${accountPrefix}${uniqueString(resourceGroup().id)}'

resource cosmosdbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: uniqueAccountName
  location : location
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
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
  name: 'cosmicworks'
  properties: {
    resource: {
        id: 'cosmicworks'
    }
  }
}

resource Container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' = {
  parent: cosmosDatabase
  name: 'products'
  properties: {
    options: {
      throughput: 400
    }
    resource: {
      id: 'products'
      partitionKey: {
        paths: [
          '/categoryId'
        ]
      }
    }
  }
}
