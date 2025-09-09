#!/usr/bin/env bash
set -e

while getopts "i:" opt 
do
	case $opt in
		i)
			ISO_PATH=$OPTARG
			;;
		?)
			echo Invalid opt -${OPTARG}
			;;
	esac
done

if [ -z "$ISO_PATH" ]; then
  echo "Usage: $0 -i <path_to_ISO>"
  exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
  echo "Live ISO file not found: $ISO_PATH"
  exit 1
fi

ISO=$(basename $ISO_PATH)
NAME=${ISO//.iso}
VM_NAME=${NAME}-test

virt-install \
        --name $VM_NAME \
        --osinfo debian11 \
        --video virtio \
        --cdrom $ISO_PATH \
        --memory 3048 \
        --vcpu $(( $(nproc) / 2 )) 
virsh destroy $VM_NAME || true
virsh undefine $VM_NAME --remove-all-storage