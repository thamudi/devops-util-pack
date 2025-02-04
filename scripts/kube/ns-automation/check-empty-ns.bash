#!/bin/bash

# List all namespaces
namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

# Iterate through each namespace and check for resources
for ns in $namespaces; do
  resources=$(kubectl get all -n $ns | wc -l)
  if [ $resources -eq 0 ]; then
    echo "Namespace $ns is empty or unused." >>/tmp/unused-ns.txt
  else
    echo "Namespace $ns has $resources resources."
  fi
done
