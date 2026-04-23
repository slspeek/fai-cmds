#! /usr/bin/env bash

set -e
FAI_CONFIG=$1
NAME=$2

if [ -z "$FAI_CONFIG" ] || [ -z "$NAME" ]; then
  echo "Usage: $0 <fai_config> <name>"
  exit 1
fi

if CLASSES=$(get-profiles.sh $FAI_CONFIG| grep  "^$NAME:"); then
  echo "$CLASSES" | cut -d: -f2- |tr ' ' ','
else
  echo "No profile found with name: $NAME" >&2
  exit 1
fi
     