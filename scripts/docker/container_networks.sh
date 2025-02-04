#!/bin/bash

containers=$(docker ps -q)

for container in $containers; do
  container_name=$(docker inspect --format '{{.Name}}' $container | sed 's/^\///')
  echo "Container: $container_name"
  docker inspect --format '{{.NetworkSettings.Networks}}' $container
  echo "---------------------------"
done
