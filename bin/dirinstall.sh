#! /bin/bash
set -e

profile_name=$1
language=$2
fai_config_dir=$3
fai_etc=$4
build_dir=$5

if [[ -z $profile_name || -z $language || -z $fai_config_dir || -z $fai_etc || -z $build_dir ]]; then
  echo "Usage: $0 <profile_name> <language> <fai_config_dir> <fai_etc> <build_dir>"
  exit 1
fi

target_dir="$build_dir/live-${profile_name}.iso-dirinstall"
cl_for_profile="$(bin/get-classes-for-profile-name.sh $fai_config_dir "$profile_name")"
# Haal INSTALL, MIRROR en BTRFS_ONE weg uit de klassenlijst, want die wil niet in een live image hebben.
# Voeg daarna de standaardklassen toe die nodig zijn voor een live image.
cl_unexpanded="$(echo "$cl_for_profile" | \
  sed -e 's/INSTALL,//; s/DEBIAN_MIRROR,//; s/BTRFS_ONE,//; s/UNATTENDED_UPGRADES,//'),${language},DHCPC,TRIXIE64,AMD64,STANDARD,TRIXIE,LIVEISO,LAST"
cl=$(bin/fai-deps-wrapper.sh $fai_config_dir "$cl_unexpanded")
if [ -z "$cl" ]; then
  echo "No classes found for profile: $profile_name"
  exit 1
fi
hostname="live-${profile_name}"
echo -e "Installing FAI configuration for $hostname with\nclasses: $cl"
sudo rm -rf "${target_dir}"
sudo mkdir -p "${target_dir}"
if ! sudo LC_ALL=C fai -v -C ${fai_etc} dirinstall -u $hostname -c $cl  -s file://${fai_config_dir} "${target_dir}" ; then
  echo "FAI installation failed for profile: $profile_name"
  sudo cat /var/log/fai/live-${profile_name}/last/error.log 

  if [ -z "$LENIENT" ] || [ "$LENIENT" = "0" ]; then
    exit 1
  else
    echo "Continuing despite FAI installation failure due to LENIENT mode."
  fi
fi
