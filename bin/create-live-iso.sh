#! /bin/bash
set -e

DESKTOP_ENVIRONMENT=$1
LANGUAGE=$2
TARGET_DIR=$3
FAI_CONFIG_DIR=$4
FAI_ETC=$5
BUILD_DIR=$6

if [ -z "$DESKTOP_ENVIRONMENT" ] || [ -z "$LANGUAGE" ] || [ -z "$TARGET_DIR" ] || [ -z "$FAI_CONFIG_DIR" ] || [ -z "$FAI_ETC" ] || [ -z "$BUILD_DIR" ]; then
    echo "Usage: $0 <desktop_environment> <language> <target_dir> <fai_config_dir> <fai_etc> <build_dir>"
    exit 1
fi
cl="DEBIAN,TRIXIE64,AMD64,STANDARD,$LANGUAGE,CALAMARES,FAIBASE,${DESKTOP_ENVIRONMENT},XORG,DHCPC,DEMO,LIVEISO,LAST"
HOSTNAME="live-${DESKTOP_ENVIRONMENT}"
echo "Installing FAI configuration for $HOSTNAME with classes: $cl"
sudo LC_ALL=C fai -v -C ${FAI_ETC} dirinstall -u $HOSTNAME -c $cl  -s file://${FAI_CONFIG_DIR} ${TARGET_DIR} || true

ISO_NAME="live-${DESKTOP_ENVIRONMENT}.iso"
echo "Creating ISO image: $ISO_NAME"
sudo fai-cd -s500 -MH -c $FAI_CONFIG_DIR -d none -g ${FAI_ETC}/grub.cfg.live -n ${TARGET_DIR} $BUILD_DIR/$ISO_NAME