#!/usr/bin/env bash
set -e

bios_opts="--boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no"

while getopts "bli:d:" opt 
do
  case $opt in
  b)
    bios_opts=
    ;;
    i)
      iso_path=$OPTARG
      ;;
  l)
    live=true
    ;;
  d)
    disk_options=$OPTARG
    ;;
    ?)
      echo Invalid opt -${OPTARG}
      ;;
  esac
done

if [ -z "$iso_path" ]; then
  echo "Usage: $0 -i <path-to-iso> [-b (BIOS boot)] [-l (live ISO)] [-d <disk options>]"
  exit 1
fi

if [ ! -f "$iso_path" ]; then
  echo "ISO file not found: $iso_path"
  exit 1
fi

iso=$(basename "$iso_path")
name=${iso//.iso}
vm_name=${name}-test

if [ -z "$disk_options" ]; then
  disk_options="--disk size=20"
fi
if [ "$live" = true ]; then
  disk_options="--disk none"
fi

virt-install \
    --name "$vm_name" \
    --osinfo debian11 \
    $bios_opts \
    --video virtio \
    --cdrom "$iso_path" \
    $disk_options \
    --memory 3048 \
    --vcpu $(( $(nproc) / 2 )) 

virsh destroy "$vm_name" || true
virsh undefine "$vm_name" --remove-all-storage --nvram
