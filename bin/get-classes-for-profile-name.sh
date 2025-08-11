#! /usr/bin/env bash

set -e
FAI_CONFIG=$1
NAME=$2

if [ -z "$FAI_CONFIG" ] || [ -z "$NAME" ]; then
  echo "Usage: $0 <fai_config> <name>"
  exit 1
fi

get-profiles.sh $FAI_CONFIG| \
     grep  "^$NAME:" | \
     cut -d: -f2- |tr ' ' ','
     