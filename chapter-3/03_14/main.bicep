 @description('Azure location where the Azure SQL Virtual Machine cluster will be created')
param location string = resourceGroup().location

@description('enable Accelerated Networking on Azure SQL Virtual Machines')
param enableAcceleratedNetworking bool

@description('Specify the resourcegroup for virtual network')
param vnetResourceGroup string = resourceGroup().name

@description('Specify the virtual network')
param vnetName string

@description('Specify the subnet under Vnet')
param subnetName string

@description('Specify the nsg name')
param networkSecurityGroupName string

@description('Azure SQL Virtual Machine name')
param virtualMachineName string

@description('Size for the Azure Virtual Machines')
param virtualMachineSize string

@description('Azure SQL Virtual Machines OS Disk type')
param osDiskType string 

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
  {
    createOption: 'empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 128
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

@description('local administrator user name for the Azure SQL Virtual Machines')
param adminUsername string

@description('SQL server connectivity option (LOCAL, PRIVATE, PUBLIC)')
@allowed([
  'LOCAL'
  'PRIVATE'
  'PUBLIC'
])
param sqlConnectivityType string

@description('SQL server port')
param sqlPortNumber int = 1433

@description('SQL server workload type (DW, GENERAL, OLTP)')
@allowed([
  'DW'
  'GENERAL'
  'OLTP'
])
param sqlStorageWorkloadType string = 'OLTP'

@description('SQL server license type (AHUB, PAYG, DR)')
@allowed([
  'AHUB'
  'PAYG'
  'DR'
])
param sqlServerLicenseType string

@description('Enable or disable EKM provider for Azure Key Vault.')
param enableAkvEkm bool

@description('Azure Key Vault name (only required when enableAkvEkm is set to true).')
param ekmAkvName string = ''

@description('name of the sql credential created for Azure Key Vault EKM provider (only required when enableAkvEkm is set to true).')
param sqlAkvCredentialName string = 'sysadmin_ekm_cred'

@description('Azure service principal Application Id for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true).')
param sqlAkvPrincipalName string = ''

@description('Azure service principal secret for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true).')
@secure()
param sqlAkvPrincipalSecret string

@description('Default path for SQL data files.')
param dataPath string = 'F:\\SQLData'

@description('Logical Disk Numbers (LUN) for SQL data disks.')
param dataDisksLUNs array = [
  0
]

@description('Default path for SQL log files.')
param logPath string = 'G:\\SQLLog'

@description('Logical Disk Numbers (LUN) for SQL log disks.')
param logDisksLUNs array = [
  1
]

@description('Default path for SQL Temp DB files.')
param tempDBPath string = 'H:\\SQLTemp'

@description('Logical Disk Numbers (LUN) for SQL Temp DB disks.')
param tempDBDisksLUNs array = [
  2
]

@description('(Optional) Create SQL Server sysadmin login user name')
param sqlAuthUpdateUserName string


@description('Enable or disable SQL server auto backup.')
param enableAutoBackup bool = false

@description('Enable or disable encryption for SQL server auto backup.')
param enableAutoBackupEncryption bool = false

@description('SQL backup retention period. 1-30 days')
param autoBackupRetentionPeriod int = 30

@description('name of the storage account used for SQL auto backup')
param autoBackupStorageAccountName string = ''

@description('Resource group for the storage account used for SQL Auto Backup')
param autoBackupStorageAccountResourceGroup string = resourceGroup().name

@description('password for SQL backup encryption. Required when \'enableAutoBackupEncryption\' is set to \'true\'.')
param autoBackupEncryptionPassword string = ''

@description('Include or exclude system databases from SQL server auto backup.')
param autoBackupSystemDbs bool = true

@description('SQL server auto backup schedule type - \'Manual\' or \'Automated\'.')
@allowed([
  'Manual'
  'Automated'
])
param autoBackupScheduleType string = 'Automated'

@description('SQL server auto backup full backup frequency - \'Daily\' or \'Weekly\'. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is \'Daily\'.')
@allowed([
  'Daily'
  'Weekly'
])
param autoBackupFullBackupFrequency string = 'Daily'

@description('SQL server auto backup full backup start time - 0-23 hours. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 23.')
param autoBackupFullBackupStartTime int = 23

@description('SQL server auto backup full backup allowed duration - 1-23 hours. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 2.')
param autoBackupFullBackupWindowHours int = 2

@description('SQL server auto backup log backup frequency - 5-60 minutes. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 60.')
param autoBackupLogBackupFrequency int = 60

@description('Enable or disable R services (SQL 2016 onwards).')
param rServicesEnabled bool = false

var tenantId = subscription().tenantId

@description('Password for VM and SQL Auth')
@minLength(12)
@secure()
param sqlVMPassword string 

resource ekm_kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = if (enableAkvEkm) {
  name : ekmAkvName
  location : location
  properties: {
    tenantId: tenantId
    accessPolicies : [
      {
        tenantId : tenantId
        objectId : sqlAkvPrincipalName
        permissions : {
          keys : [
            'get'
            'list'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
    sku : {
      family : 'A'
      name : 'standard'
    }
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

module backup_storage_account './storage-account.bicep' = if (enableAutoBackup) {
  name: 'backupStorageAccount'
  params: {
    location: location
    name: autoBackupStorageAccountName
  }
}

module sql_vm './azure-sqlvm.bicep' = {
  name: 'sqlVM-1'
  params: {
    location: location
    enableAcceleratedNetworking: enableAcceleratedNetworking
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    subnetName: subnetName
    virtualMachineName: virtualMachineName
    virtualMachineSize: virtualMachineSize
    osDiskType: osDiskType
    dataDisks: dataDisks
    imageType: imageType
    imageSku: imageSku
    publisher: publisher
    adminUsername: adminUsername
    adminPassword: sqlVMPassword
    sqlConnectivityType: sqlConnectivityType
    sqlPortNumber: sqlPortNumber
    sqlStorageWorkloadType: sqlStorageWorkloadType
    sqlServerLicenseType: sqlServerLicenseType
    enableAkvEkm: enableAkvEkm
    sqlAkvUrl: enableAkvEkm ? ekm_kv.properties.vaultUri : ''
    sqlAkvCredentialName: sqlAkvCredentialName
    sqlAkvPrincipalName: sqlAkvPrincipalName
    sqlAkvPrincipalSecret: sqlAkvPrincipalSecret
    dataPath: dataPath
    dataDisksLUNs: dataDisksLUNs
    logPath: logPath
    logDisksLUNs: logDisksLUNs
    tempDBPath: tempDBPath
    tempDBDisksLUNs: tempDBDisksLUNs
    sqlAuthUpdateUserName: sqlAuthUpdateUserName
    sqlAuthUpdatePassword: sqlVMPassword
    enableAutoBackup: enableAutoBackup
    enableAutoBackupEncryption: enableAutoBackupEncryption
    autoBackupRetentionPeriod: autoBackupRetentionPeriod
    autoBackupStorageAccountName: backup_storage_account.outputs.name
    autoBackupStorageAccountResourceGroup: autoBackupStorageAccountResourceGroup
    autoBackupEncryptionPassword: autoBackupEncryptionPassword
    autoBackupSystemDbs: autoBackupSystemDbs
    autoBackupScheduleType: autoBackupScheduleType
    autoBackupFullBackupFrequency: autoBackupFullBackupFrequency
    autoBackupFullBackupStartTime: autoBackupFullBackupStartTime
    autoBackupFullBackupWindowHours: autoBackupFullBackupWindowHours
    autoBackupLogBackupFrequency: autoBackupLogBackupFrequency
    rServicesEnabled: rServicesEnabled
  }
  dependsOn: [
    backup_storage_account
    virtualNetwork
  ]
}

output ekm_kv_id string = enableAkvEkm ? ekm_kv.id : ''
