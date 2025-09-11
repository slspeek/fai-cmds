#! /bin/bash
set -e

PROFILE_NAME=$1
LANGUAGE=$2
FAI_CONFIG_DIR=$3
FAI_ETC=$4
BUILD_DIR=$5

if [ -z "$PROFILE_NAME" ] || [ -z "$LANGUAGE" ] || [ -z "$FAI_CONFIG_DIR" ] || [ -z "$FAI_ETC" ] || [ -z "$BUILD_DIR" ]; then
  echo "Usage: $0 <profile_name> <language> <fai_config_dir> <fai_etc> <build_dir>"
  exit 1
fi

TARGET_DIR="$BUILD_DIR/live-${PROFILE_NAME}"

cl_unexpanded="$(bin/get-classes-for-profile-name.sh $FAI_CONFIG_DIR "$PROFILE_NAME"|\
  sed -e 's/INSTALL,//'),${LANGUAGE},DHCPC,TRIXIE64,AMD64,STANDARD,TRIXIE,LIVEISO,LAST"
cl=$(bin/fai-deps-wrapper.sh $FAI_CONFIG_DIR "$cl_unexpanded")
if [ -z "$cl" ]; then
  echo "No classes found for profile: $PROFILE_NAME"
  exit 1
fi
HOSTNAME="live-${PROFILE_NAME}"
echo -e "Installing FAI configuration for $HOSTNAME with\nclasses: $cl"
sudo rm -rf "${TARGET_DIR}"
sudo mkdir -p "${TARGET_DIR}"
if ! sudo LC_ALL=C fai -v -C ${FAI_ETC} dirinstall -u $HOSTNAME -c $cl  -s file://${FAI_CONFIG_DIR} "${TARGET_DIR}" ; then
  echo "FAI installation failed for profile: $PROFILE_NAME"
  sudo cat /var/log/fai/live-${PROFILE_NAME}/last/error.log 

  if [ -z "$LENIENT" ] || [ "$LENIENT" = "0" ]; then
    exit 1
  else
    echo "Continuing despite FAI installation failure due to LENIENT mode."
  fi
fi
ISO_NAME="live-${PROFILE_NAME}.iso"
echo "Creating ISO image: $ISO_NAME"
sudo fai-cd -fMH $FAI_CD_LIVE_OPTS -c $FAI_CONFIG_DIR -d none -g ${FAI_ETC}/grub.cfg.live -n "${TARGET_DIR}" "$BUILD_DIR/$ISO_NAME"