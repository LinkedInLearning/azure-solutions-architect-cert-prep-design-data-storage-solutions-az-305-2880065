param location string = resourceGroup().location

@description('Virtual Machine name')
param virtualMachineName string

@description('Size for the Azure Virtual Machines')
param virtualMachineSize string

@description('Virtual Machines OS Disk type')
param osDiskType string = 'Premium_LRS'

@description('data disk configurations for the Azure Virtual Machines')
param dataDisks array = [
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 64
  }
  {
    createOption: 'empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
]

@description('Image type')
@allowed([
  'SQL2017-WS2016'
  'SQL2016SP2-WS2016'
  'SQL2019-WS2019'
  'SQL2019-WS2019'
  'WindowsServer'
  
])
param imageType string

@description('Image SKU')
@allowed([
  'Developer'
  'Enterprise'
  'Standard'
  '2019-Datacenter'
])
param imageSku string

@description('Image publisher')
@allowed([
  'MicrosoftSQLServer'
  'MicrosoftWindowsServer'
])
param publisher string

@description('local administrator user name for the Virtual Machines')
param adminUsername string

@description('local administrator password for the Virtual Machines')
@secure()
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: publisher
        offer: imageType
        sku: imageSku
        version: 'latest'
      }
      dataDisks: [for (item, j) in dataDisks: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        managedDisk: {
          storageAccountType: item.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'nic-${virtualMachineName}')
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
  }
}
output VMId string = vm.id
