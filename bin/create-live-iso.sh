#! /bin/bash
set -e

profile_name=$1
fai_config_dir=$2
fai_etc=$3
build_dir=$4

if [[ -z $profile_name || -z $fai_config_dir || -z $fai_etc || -z $build_dir ]]; then
  echo "Usage: $0 <profile_name> <fai_config_dir> <fai_etc> <build_dir>"
  exit 1
fi

dirinstall_dir="$build_dir/live-${profile_name}.iso-dirinstall"
iso_name="live-${profile_name}.iso"

echo "Creating ISO image: $iso_name"
sudo fai-cd -fMH $FAI_CD_LIVE_OPTS -c $fai_config_dir -d none -g ${fai_etc}/grub.cfg.live -n "${dirinstall_dir}" "$build_dir/$iso_name"
