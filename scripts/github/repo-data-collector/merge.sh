#!/bin/bash

# Check if active_repos.csv exists
if [[ -f "active_repos.csv" ]]; then
  echo "active_repos.csv found. Processing..."

  # Create a temporary file to store the updated repositories-private.csv
  temp_file=$(mktemp)

  # Read active_repos.csv into an array
  declare -A active_repos
  while IFS=, read -r repo_name; do
    active_repos["$repo_name"]=true
  done < <(awk -F, 'NR>1 {print $2}' active_repos.csv)

  # Debugging: Print the active_repos array
  echo "Active Repositories:"
  for repo in "${!active_repos[@]}"; do
    echo "$repo"
  done

  # Process repositories-private.csv and update the CI/CD Integration column
  awk -F, -v OFS=, -v active_repos="${!active_repos[*]}" '
  BEGIN {
    split(active_repos, arr, " ")
    for (i in arr) {
      active[arr[i]] = 1
    }
  }
  NR==1 {
    for (i=1; i<=NF; i++) {
      if ($i == "CI/CD Integration") {
        cicd_col = i
      }
    }
    print $0
  }
  NR>1 {
    # Debugging: Print the repository name being checked
    print "Checking repository:", $3 > "/dev/stderr"
    if ($3 in active) {
      print "Match found for:", $3 > "/dev/stderr"
      $cicd_col = "Enabled"
    } else {
      print "No match for:", $3 > "/dev/stderr"
      $cicd_col = "Disabled"
    }
    print $0
  }' repositories-private.csv >"$temp_file"

  # Replace the original repositories-final.csv with the updated one
  mv "$temp_file" repositories-final.csv

  echo "CI/CD Integration column has been updated in repositories-final.csv"
else
  echo "active_repos.csv not found. Skipping CI/CD Integration column update."
fi
