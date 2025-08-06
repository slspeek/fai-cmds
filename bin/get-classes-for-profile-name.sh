#! /usr/bin/env bash

set -e
FAI_CONFIG=$1
NAME=$2

if [ -z "$FAI_CONFIG" ] || [ -z "$NAME" ]; then
  echo "Usage: $0 <fai_config> <name>"
  exit 1
fi

cat $FAI_CONFIG/class/*.profile | \
  awk '/^Name: / {for(i=2; i<=NF; i++){printf("%s", $i);\
     if(i!=NF){printf(" ")}}} \
     /^Classes: / \
     {printf(":");for(i=2; i <=NF; i++){printf ("%s", $i);\
     if(i!=NF){printf(" ")}}; print("")} '| \
     grep  "^$NAME:" | \
     cut -d: -f2- |tr ' ' ','
     