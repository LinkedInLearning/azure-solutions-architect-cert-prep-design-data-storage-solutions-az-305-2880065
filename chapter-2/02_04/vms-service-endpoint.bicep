@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2as_v4'

@description('Location for all resources.')
param location string = resourceGroup().location

var vmVars = [
  {
    prefix: 'allow'
    subnetPrefix: '10.0.0.0/24'
  }
  {
    prefix: 'deny'
    subnetPrefix: '10.0.1.0/24'
  }
]

module vm 'vm.bicep' = [for vmIdx in vmVars: {
  name: 'vm${vmIdx.prefix}'
  params:{
    name: 'vm${vmIdx.prefix}'
    location: location
    vnetName:vnet.name
    subnetName: 'subnet${vmIdx.prefix}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword

  }
}]

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsgsendpoint'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnetSEndpoint'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [for subnet in vmVars: {
      name: 'subnet${subnet.prefix}'
      properties: {
        addressPrefix: subnet.subnetPrefix
        networkSecurityGroup: {
          id: securityGroup.id
        }
      }
    }]
  }
}
