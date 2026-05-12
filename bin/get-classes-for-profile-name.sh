#! /usr/bin/env bash

set -e
fai_config=$1
name=$2

if [[ -z $fai_config || -z $name ]]; then
  echo "Usage: $0 <fai_config> <name>"
  exit 1
fi

if classes=$(get-profiles.sh "$fai_config" | grep "^$name:"); then
  echo "$classes" | cut -d: -f2- | tr ' ' ','
else
  echo "No profile found with name: $name" >&2
  exit 1
fi
