#!/bin/bash

# Read the JSON file
repos=$(jq -c '.[]' helm_repos.json)

# Loop through each repository and add it to Helm
for repo in $repos; do
  name=$(echo $repo | jq -r '.name')
  url=$(echo $repo | jq -r '.url')
  helm repo add $name $url
done

# Update the repositories
helm repo update
