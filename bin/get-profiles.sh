#! /usr/bin/env bash

set -e
FAI_CONFIG=$1

for PROFILE in $FAI_CONFIG/class/*.profile;
do 
  cat $PROFILE
  echo
done| \
  awk '/^Name: / {for(i=2; i<=NF; i++){printf("%s", tolower($i));\
     if(i!=NF){printf("-")}}} \
     /^Classes: / \
     {printf(":");for(i=2; i <=NF; i++){printf ("%s", $i);\
     if(i!=NF){printf(" ")}}; print("")} '|grep -v sysinfo|grep -v inventory
     