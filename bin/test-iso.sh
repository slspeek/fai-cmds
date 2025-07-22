#!/usr/bin/env bash
set -e

while getopts "i:" opt 
do
	case $opt in
		i)
			LIVE_ISO_PATH=$OPTARG
			;;
		?)
			echo Invalid opt -${OPTARG}
			;;
	esac
done

if [ -z "$LIVE_ISO_PATH" ]; then
  echo "Usage: $0 -i <path_to_live_iso>"
  exit 1
fi

if [ ! -f "$LIVE_ISO_PATH" ]; then
  echo "Live ISO file not found: $LIVE_ISO_PATH"
  exit 1
fi

LIVE_ISO=$(basename $LIVE_ISO_PATH)
LIVE_NAME=${LIVE_ISO//.iso}
VM_NAME=${LIVE_NAME}-test

virt-install \
        --name $VM_NAME \
        --osinfo debian11 \
        --video virtio \
        --cdrom $LIVE_ISO_PATH \
        --memory 3048 \
        --vcpu 2 
virsh destroy $VM_NAME || true
virsh undefine $VM_NAME --remove-all-storage