#! /usr/bin/env bash

set -e
fai_config=$1
if [[ -z $fai_config ]]; then
  echo "Usage: $0 <fai_config>"
  exit 1
fi

for profile in "$fai_config"/class/*.profile;
do 
  cat "$profile"
  echo
done| \
  awk '
    /^Name: / {
      for(i=2; i<=NF; i++){
      printf("%s", tolower($i))
      if(i!=NF){printf("-")}
      }
    } 
    /^Classes: / {
      printf(":");
      for(i=2; i <=NF; i++){
        printf ("%s", $i)
        if(i!=NF){printf(" ")
        }
      }
      print("")
    } '|grep -v sysinfo|grep -v inventory
     