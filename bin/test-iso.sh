#!/usr/bin/env bash
set -e

while getopts "li:" opt 
do
	case $opt in
		i)
			ISO_PATH=$OPTARG
			;;
    l)
      LIVE=true
      ;;
		?)
			echo Invalid opt -${OPTARG}
			;;
	esac
done

if [ -z "$ISO_PATH" ]; then
  echo "Usage: $0 -i <path-to-iso> [-l]"
  echo "  -i <path-to-iso> : Path to the ISO file to test"
  echo "  -l               : Indicate that this is a live ISO (no disk)"
  exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
  echo "ISO file not found: $ISO_PATH"
  exit 1
fi

ISO=$(basename $ISO_PATH)
NAME=${ISO//.iso}
VM_NAME=${NAME}-test

DISK_OPTIONS="--disk size=20"
if [ "$LIVE" = true ]; then
  DISK_OPTIONS="--disk none"
fi


virt-install \
        --name $VM_NAME \
        --osinfo debian11 \
        --video virtio \
        --cdrom $ISO_PATH \
        $DISK_OPTIONS \
        --memory 3048 \
        --vcpu $(( $(nproc) / 2 )) 

virsh destroy $VM_NAME || true
virsh undefine $VM_NAME --remove-all-storage
