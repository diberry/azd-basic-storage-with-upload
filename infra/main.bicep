targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

param storageAccountName string = ''
param storageContainerName string = ''

@secure()
param storageAccountKey string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

/////////// Common ///////////


module storageAccount './core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    allowBlobPublicAccess: true
    location: location
    containers: [
      {
        name: !empty(storageContainerName) ? storageContainerName : 'stc${resourceToken}'
        publicAccess: 'Blob'
      }
    ]
  }
}
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output STORAGE_ACCOUNT_NAME string = storageAccount.outputs.name
output STORAGE_ACCOUNT_KEY string = storageAccount.outputs.key
output STORAGE_CONTAINER_NAME string = storageContainerName
