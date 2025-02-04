#!/bin/bash

# This script collects data from a GitHub repository.
#
# Before running this script, ensure you have exported your GitHub username and token as environment variables.
#
# Usage:
#   export GITHUB_USERNAME=<your_github_username>
#   export GITHUB_TOKEN=<your_github_token>
#   ./gh.sh
#
# Replace <your_github_username> and <your_github_token> with your actual GitHub username and personal access token.
#
# Note: Your GitHub token should have the necessary permissions to access the repository data.

USERNAME=${USERNAME:-"default_username"}
TOKEN=${TOKEN:-"default_token"}

# No of repositories per page - Maximum Limit is 100
PERPAGE=100

# Change the BASEURL to your Org or User based
# Org base URL
BASEURL="https://api.github.com/orgs/jordanopensource/repos"

# User base URL
# BASEURL="https://api.github.com/user/<your_github_username>/repos"

# Fetch the first page to calculate the total number of pages
response=$(curl -s -u $USERNAME:$TOKEN -H "Accept: application/vnd.github.v3+json" ${BASEURL}\?per_page\=${PERPAGE})

# Debugging: Print the response
echo "Response: $response"

# Calculating the Total Pages after enabling Pagination
TOTALPAGES=$(echo "$response" | jq -r 'if . | length == 0 or .[0].total_count == null then 1 else (.total_count / '"$PERPAGE"') | ceil end')

# Debugging: Print the total pages
echo "Total Pages: $TOTALPAGES"

# Check if TOTALPAGES is set and is a valid number
if [[ -z "$TOTALPAGES" || ! "$TOTALPAGES" =~ ^[0-9]+$ ]]; then
  echo "Failed to determine the total number of pages. Exiting."
  exit 1
fi

i=1

# CSV Header
echo "QuickLink,Repository Health,Repository Name,Owner,Repository Visibility,Archived, Access Control Lists,Default Branch,Repository Size,Repository Rulesets,CI/CD Integration,Automated Testing,Last Commit on Default Branch,Contributions Guide,License,Templates (issues, PRs),Security Compliance" >repositories-private.csv

until [ $i -gt $TOTALPAGES ]; do
  result=$(curl -s -u $USERNAME:$TOKEN -H 'Accept: application/vnd.github.v3+json' ${BASEURL}?per_page=${PERPAGE}\&page=${i} 2>&1)

  # Check if the result is valid JSON
  if echo "$result" | jq empty; then
    echo "$result" >tempfile

    jq -r '.[] | [
      .html_url,
      "Healthy", # Placeholder for Repository Health
      .name,
      .owner.login,
      .visibility,
      .archived,
      "N/A", # Placeholder for Access Control Lists
      .default_branch,
      (.size / 1024 | tostring),
      "N/A", # Placeholder for Repository Rulesets,
      "N/A", # Placeholder for CI/CD Integration
      "N/A", # Placeholder for Automated Testing
      .pushed_at,
      "N/A", # Placeholder for Contributions Guide
      .license.spdx_id // "N/A",
      "N/A", # Placeholder for Templates (issues, PRs)
      "N/A" # Placeholder for Security Compliance
    ] | @csv' tempfile >>repositories-private.csv
  else
    echo "Error: Received invalid JSON from GitHub API"
    exit 1
  fi

  ((i++))
done

echo "Repository data has been saved to repositories-private.csv"
