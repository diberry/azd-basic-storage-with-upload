#!/usr/bin/env bash
##############################################################################
# Usage: ./upload.sh 
# Upload all files in <sourceDir> to Azure Storage <container>.
# Environment must have values for STORAGE_ACCOUNT_NAME and STORAGE_ACCOUNT_KEY
##############################################################################
# v1.0.0 | dependencies: Azure CLI
##############################################################################
trap 'echo "# $BASH_COMMAND"' DEBUG
scriptdir="$(dirname "$0")"
cd "$scriptdir"

storageAccountName="$STORAGE_ACCOUNT_NAME"
storageAccountKey="$STORAGE_ACCOUNT_KEY"
container="$STORAGE_CONTAINER_NAME"

echo "$storageAccountName"
echo "$storageAccountKey"
echo "$container"

# Begin upload
echo "Uploading files to Azure Storage..."

cd "../"

az storage blob upload-batch --account-name $storageAccountName --account-key $storageAccountKey --destination $container --source ./blobs/ --pattern *.jpg

# list blobs in container and count the number of lines in the output
blobCount=$(az storage blob list --account-name "$storageAccountName" --account-key "$storageAccountKey" --container-name "$container" --query "[].name" --output tsv | wc -l)

# check if the blob count is greater than 0
if [[ "$blobCount" -gt 0 ]]; then
  echo "The container has $blobCount blobs."
else
  echo "The container is empty."
  exit 1
fi

echo "Upload files to Azure Storage completed"