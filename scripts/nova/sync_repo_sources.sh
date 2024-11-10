#!/bin/bash

# Function to check if a package is installed
check_package() {
  if ! command -v $1 &>/dev/null; then
    echo "Package $1 is not installed."
    if [ "$1" == "yq" ]; then
      echo "You can download it from the GitHub page: https://github.com/mikefarah/yq?tab=readme-ov-file#install"
    elif [ "$1" == "dyff" ]; then
      echo "You can download it from the GitHub page: https://github.com/homeport/dyff?tab=readme-ov-file#installation"
    else
      echo "Please install $1 and try again."
    fi
    exit 1
  fi
}

# Check if packages are installed
check_package "yq"
check_package "dyff"

# Find JOSA cloud dir
target_dir=$(find ~ -type d -name "josa-cloud")

# Directory containing YAML files
repo_directory="$target_dir/sources/repositories/"

# Output file
output_file="/tmp/output_urls.yaml"

# Create a YAML file with the initial structure:
echo "url: []" >"$output_file"

# Find YAML files, extract URL values, and save to output file
find "$repo_directory" -name "*.yaml" -exec sh -c 'url=$(yq eval ".spec.url" "$1"); [ -n "$url" ] && yq eval --inplace ".url += [\"$url\"]" '$output_file'' sh {} \;

# Clean up null values
yq eval '.url |= map(select(. != "null"))' $output_file -i

# Check the dyff between the two yaml files
dyff between config.yaml $output_file

yq eval-all '. as $item ireduce ({}; . * $item) | .url = (load("'"$output_file"'") | .url)' config.yaml >tmp.yaml

# Sort
yq eval '.url |= sort' tmp.yaml >config.yaml

# Cleanup remaining files
rm $output_file && rm tmp.yaml
