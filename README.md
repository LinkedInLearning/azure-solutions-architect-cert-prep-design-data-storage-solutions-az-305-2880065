# Azure Solutions Architect Cert Prep: Design Data Storage Solutions (AZ-305)
This is the repository for the LinkedIn Learning course Azure Solutions Architect Cert Prep: Design Data Storage Solutions (AZ-305). The full course is available from [LinkedIn Learning][lil-course-url].

## Instructions
This repository has chapters and then folders for each of the videos with demos in the course. The naming convention is `CHAPTER-#/CHAPTER#_MOVIE#`. As an example, folder structure of `chapter-2/02_03` corresponds to the second chapter and the third video in that chapter.

Each chapter has a readme file giving the Azure CLI commands to be used to create the environments in the corresponding video. The Azure CLI commands use [Azure Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) to deploy resources to the specified resource group.

The files in this repository are not exercise files, they have been designed so that the environments shown in the demos can be built and learners can follow along.


## Installing

The files in this repository require no additional software to be installed locally. The repository can be checked out directly to the Azure Cloudshell within the Azure Portal. However, it is recommended to install Visual Studio Code locally, in order to view the Azure CLI commands and the Azure Bicep files:

1. Install [Visual Studio Code](https://code.visualstudio.com/) locally, following the instructions for you operating system.
2. Install the [Azure Bicep Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) to Visual Studio Code locally.
3. Install the [Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) to Visual Studio Code locally.
4. Clone the repository to the Azure Cloudshell using:
	- git checkout https://github.com/LinkedInLearning/azure-solutions-architect-cert-prep-design-data-storage-solutions-az-305-2880065.git

    And locally using the same command to view the Azure bicep files in Visual Studio Code.
5. In the local Visual Studio Code open the chapter specific readme for the Azure CLI commands for each video. 
6. `cd` into the chapter and video folders in the Azure Cloudshell and paste in the commands and execute them to create an environment.

Steps 5 and 6 are demonstrated in Chapter 2 - Video 2.


[0]: # (Replace these placeholder URLs with actual course URLs)

[lil-course-url]: https://www.linkedin.com/learning/
[lil-thumbnail-url]: http://

