#!/bin/bash

input_file="$PWD/connection-strings.txt"

if [[ ! -f $input_file ]]; then
  echo "File $input_file does not exist."
  exit 1
fi

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  node_name="${line##*#}"

  response=$(docker run -e CONNECTION_STRING="$line" bubatzlegal/webtunnel-client:latest)

  if [[ $? -ne 0 ]]; then
    echo "Docker command failed for node $node_name"
    continue
  fi

  if [[ $response == *'"IsTor":false'* ]]; then
    echo "$node_name: False"
    exit 1
  elif [[ $response == *'"IsTor":true'* ]]; then
    echo "$node_name: True"
  else
    echo "Something went really wrong for node $node_name"
    exit 1
  fi
done < "$input_file"