#!/bin/bash

# This script collects data from a drone.
#
# Before running this script, ensure you have exported your drone server and token as environment variables.
#
# Usage:
#   export DRONE_SERVER=<your_drone_server>
#   export DRONE_TOKEN=<your_drone_token>
#   ./gh.sh
#
# Replace <your_drone_server> and <your_drone_token> with your actual drone server and personal access token.
#
# Note: Your drone token should have the necessary permissions to access the repository data.

DRONE_SERVER=${DRONE_SERVER:-"default_server"}
DRONE_TOKEN=${DRONE_TOKEN:-"default_token"}

# CSV Header
echo "Namespace,Name,Slug,Git HTTP URL,Git SSH URL,Link,Default Branch,Visibility,Private" >active_repos.csv

# Fetch all repositories
response=$(curl -s -H "Authorization: Bearer $DRONE_TOKEN" "${DRONE_SERVER}")

# Debugging: Print the response
echo "$response" >temp.json

# Check if the response is valid JSON
if echo "$response" | jq empty; then
  # Filter active repositories and append their details to the CSV file
  echo "$response" | jq -r '.[] | select(.active == true) | [
    .namespace,
    .name,
    .slug,
    .git_http_url,
    .git_ssh_url,
    .link,
    .default_branch,
    .visibility,
    .private
  ] | @csv' >>active_repos.csv
else
  echo "Error: Received invalid JSON from Drone CI API"
  exit 1
fi

echo "Active repositories have been saved to active_repos.csv"
