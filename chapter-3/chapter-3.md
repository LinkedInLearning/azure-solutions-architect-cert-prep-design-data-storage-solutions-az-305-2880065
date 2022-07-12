## Bicep demos for chapter 3 - Azure SQL, SQL MI and SQL VM

## 03_01 - logical server

Create a logical Server for Azure SQL DB.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-intro-sql --location <location>

    az deployment group create --resource-group rg-intro-sql --template-file azuresqldb-server.bicep

## 03_02 - purchasing models

To follow the demo in the video, create the logical server using the script in 03_01 and the Azure CLI command above.

Create a single DTU Azure SQL DB

    az account set --subscription <subscriptionid>
    
    az group create --name rg-purchasing-sql --location <location>

    az deployment group create --resource-group rg-purchasing-sql --template-file azuresqldb-dtu.bicep

Create a single DTU Azure SQL DB but change the SKU to an S10 SQL DB

    az deployment group create --resource-group rg-purchasing-sql --template-file azuresqldb-dtu.bicep --parameters skuName=S10

Create a vCore Azure SQL DB

    az deployment group create --resource-group rg-purchasing-sql --template-file azuresqldb-vcore.bicep

## 03_03 - service tiers

Create a single GP or Business critical

    az account set --subscription <subscriptionid>
    
    az group create --name rg-tier-sql --location <location>

    az deployment group create --resource-group rg-tier-sql --template-file azuresqldb-vcore.bicep

The following creates a Business Critical Azure SQL DB, these are often twice the price of General Purpose, don't forget to tear it back down again!

    az deployment group create --resource-group rg-tier-sql --template-file azuresqldb-vcore.bicep --parameters skuTier=BusinessCritical

## 03_04 - pre-provisioned compute

Create an elastic pool for Azure SQL DB

    az account set --subscription <subscriptionid>
    
    az group create --name rg-elastic-sql --location <location>

    az deployment group create --resource-group rg-elastic-sql --template-file azuresqldb-vcore.bicep

The following creates a Business Critical Azure SQL DB, these are often twice the price of General Purpose, don't forget to tear it back down again!

    az deployment group create --resource-group rg-elastic-sql --template-file azuresqldb-vcore.bicep --parameters skuTier=BusinessCritical


## 03_05 - Serverless

Create a serverless vCore Db

    az account set --subscription <subscriptionid>
    
    az group create --name rg-serverless-sql --location <location>

    az deployment group create --resource-group rg-serverless-sql --template-file azuresqldb-serverless.bicep


## 03_06 - Scaling options

Create a vCore Db (to test dynamic scaling)

    az account set --subscription <subscriptionid>
    
    az group create --name rg-scaling-sql --location <location>

    az deployment group create --resource-group rg-scaling-sql --template-file azuresqldb-vcore.bicep --parameters serverPrefix=az305serv

Scale to 4 vCores - Make sure you use the same server prefix!

    az deployment group create --resource-group rg-scaling-sql --template-file azuresqldb-vcore.bicep --parameters serverPrefix=az305serv skuName=GP_Gen5_4


## 03_07 - Encryption at rest and in transit

Create a vCore Db (to test encrypted connect string and bring your own TDE protector)

    az account set --subscription <subscriptionid>
    
    az group create --name rg-encrypt-sql --location <location>

    az deployment group create --resource-group rg-encrypt-sql --template-file azuresqldb-vcore.bicep

Get your user's objectID

    az ad signed-in-user show --query objectId -o tsv

Create a keyvault and pass in your objectId to grant access to setup CMK

    az deployment group create --resource-group rg-encrypt-sql --template-file keyvault.bicep --parameters userObjectId=<>

Create a Key Vault with User Managed Identity to use CMK from creation

    az deployment group create --resource-group rg-encrypt-sql --template-file keyvault-umi.bicep --parameters serverPrefix=az305cmk userObjectId=<>



## 03_08 - Always Encrypted

Create a vCore Db 

    az account set --subscription <subscriptionid>
    
    az group create --name rg-alwaysencrypted-sql --location <location>

    az deployment group create --resource-group rg-alwaysencrypted-sql --template-file azuresqldb-vcore.bicep

Get your user's objectID

    az ad signed-in-user show --query objectId -o tsv

Create a keyvault pass in your objectId to grant access to setup CMK

    az deployment group create --resource-group rg-alwaysencrypted-sql --template-file keyvault.bicep --parameters userObjectId=<>

Use the create-employee-table.sql script for the demo


## 03_09 - Dynamic Data Masking

Create a vCore Db, this script requires two test users to have been created in Azure AD which are not your logged in user

    az account set --subscription <subscriptionid>
    
    az group create --name rg-datamasking-sql --location <location>

Get your user's objectID

    az ad signed-in-user show --query objectId -o tsv

Create an Azure SQL DB with Azure AD authenticaiton enabled

    az deployment group create --resource-group rg-datamasking-sql --template-file azuresqldb-vcore-adauth.bicep --parameters adminObjectId=<> adminUPN=<>

Use the create-members.sql script for the demo


## 03_10 - Azure SQL Audit

    az account set --subscription <subscriptionid>
    
    az group create --name rg-audit-sql --location <location>

Create two storage accounts in different regions, one in the same region as the Azure SQL DB

    az deployment group create --resource-group rg-audit-sql --template-file storage-standard.bicep --parameters secondLocation=<>

Create a vcore db

    az deployment group create --resource-group rg-audit-sql --template-file azuresqldb-vcore.bicep
    

## 03_11 - High Availability and Business Continuity

    az account set --subscription <subscriptionid>
    
    az group create --name rg-habc-sql --location <location>

Create a General Purpose Zone redundant Azure SQL DB, at time of writing some regions that support zone redundancy were not yet supported, some were in GA and some in preview. Check this link - [High availability - Azure SQL Database and SQL Managed Instance | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-sql/database/high-availability-sla?view=azuresql&tabs=azure-powershell#general-purpose-service-tier-zone-redundant-availability)

    az deployment group create --resource-group rg-habc-sql --template-file azuresqldb-zonal.bicep

Create a vcore DB to setup geo-replication from

    az deployment group create --resource-group rg-habc-sql --template-file azuresqldb-geo-replication.bicep

Manually create a second blank server in the portal for auto failover group usage in a different region.

(At the time of writing, the portal was not picking up servers created byBicep for secondaries)


## 03_12 - Performance tuning and monitoring

Note - https://github.com/microsoft/sqlworkshops-azuresqlworkshop this demo is based on the performance section of this excellent workshop from the SQL team at Microsoft.

This takes over 24 hours to populate data for the demo - so be careful of your costs.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-perf-sql --location <location>

Create a logical server and a log analytics workspace

    az deployment group create --resource-group rg-perf-sql --template-file azuresqldb-vcore.bicep

    adminUsername sqladmin

    Password adminPass123!!!

Create a VM to introduce load to the Azure SQL DB

    az deployment group create --resource-group rg-perf-sql --template-file windows10-vm.bicep --parameters adminUsername=sqladmin

    Password adminPass123!!!

Setup the VM to create load on the Azure SQL DB

 1. Login to the VM and istall - https://www.microsoft.com/en-us/download/details.aspx?id=103126

 2. Download and install developer edition, choose a basic install type - https://www.microsoft.com/en-gb/sql-server/sql-server-downloads?rtc=1

 3. Download and install SSMS if you do not have access to it locally

 4. Install git - https://git-scm.com/download/win
 
 5. Clone this repo onto the VM - git clone https://github.com/microsoft/sqlworkshops-azuresqlworkshop.git

 6. Restore the adeventureworks2017LT db to the SQL Server on the VM - https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak

    Follow this guide for restoring the backup if you need to - https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/quickstart-backup-restore-database?view=sql-server-ver16

 7. Add Access to any Azure service through the network settings of the logical server

 8. Run sqlworkshops-azuresqlworkshop\azuresqlworkshop\04-Performance\tuning_applications\order_rating_dll.sql on the database from SSMS.

 9. Deploy the adventureworks database from the SQL VM to the Azure SQL Server (Right click on database in SSMS, tasks, deploy to Azure SQL). Choose SQL Server Authentication, the servername is on the top right of the logical server overview page, the username and apssword are as entered when the logical server was created above. Once this is done you can disable the SQL service if you need to save resources on your VM.

 10. Setup diagnostic logging and metric logging for the database, pass in the logical server name and the Azure SQL DB name. The servername only requires the first part before the point - ie not database.windows.net

        az deployment group create --resource-group rg-perf-sql --template-file azuresql-diagnostics.bicep --parameters servername=<> dbname=<>

 11. On the VM in powershell cd to the local git repository sqlworkshops-azuresqlworkshop\azuresqlworkshop\04-Performance and edit \monitor_and_scale\sqlworkdload.cmd. You may also need to set the path to ostress (C:\Program Files\Microsoft Corporation\RMLUtils)

        ostress.exe -S<servername>.database.windows.net -itopcustomersales.sql -Usqladmin -d<dbname> -P<password> -n10 -r10 -q

    There are also cmd files in the other performance directories, edit those , starting with r10 and the path to ostress and run them to create load (one at a time), ensure they all complete within 15 minutes if you are to continue with step 12. The values given for threads and runs were set for a S1 DTU model DB with 20 DTU.

12. To create continuous load run the cmd files staggered in Task Scheduler, you will need to set the action to start in the directory the cmd files are in. It takes about a days load from inserting and selecting on the non-indexed table to get a tuning recommendation. There are scripts in this folder to overwrite the ones from the github repo, these will run if correctly spaced apart for 15 minutes and will gradually increase the load on the database adding more and more rows.


## 03_14 - SQLVM IaaS Agent

Create a VNET and Subnet, optionally create a key vault, then create a Azure SQL VM and a VM of the same spec but no SQL. The second VM has a public IP addres and NSG opeen for RDP which will allow manual installation of SQL Server.

    az account set --subscription <subscriptionid>
    
    az group create --name rg-sqlvm-sql --location

    az deployment group create --name 'sql-vm-non-sql-vm' --resource-group rg-sqlvm-sql --template-file main.bicep --parameters deploy-sqlvm.parameters.json --verbose

Now RDP to the VM Without SQL Installed and manually setup the partitions for F, G, H drives and install SQL Developer Edition and configure data on F, Logs on G and tempdb on H.

Now register the SQL IaaS Agent Extension in full mode, this is a hybrid benefit license as you have installed Developer Edition (PAYG), AHUB is hybrind benefit for Enterprise or Standard Edn with software assurance and DR for a free DR replica.

    az sql vm create --name az305mansql --resource-group rg-sqlvm-sql --location <vm_location> --license-type AHUB --sql-mgmt-type Full