#! /bin/bash
set -e

PROFILE_NAME=$1
FAI_CONFIG_DIR=$2
FAI_ETC=$3
BUILD_DIR=$4

if [ -z "$PROFILE_NAME" ] || [ -z "$FAI_CONFIG_DIR" ] || [ -z "$FAI_ETC" ] || [ -z "$BUILD_DIR" ]; then
  echo "Usage: $0 <profile_name> <fai_config_dir> <fai_etc> <build_dir>"
  exit 1
fi

DIRINSTALL_DIR="$BUILD_DIR/live-${PROFILE_NAME}.iso-dirinstall"


ISO_NAME="live-${PROFILE_NAME}.iso"
echo "Creating ISO image: $ISO_NAME"
sudo fai-cd -fMH $FAI_CD_LIVE_OPTS -c $FAI_CONFIG_DIR -d none -g ${FAI_ETC}/grub.cfg.live -n "${DIRINSTALL_DIR}" "$BUILD_DIR/$ISO_NAME"
# Workaround for umount issues on some systems
sudo umount "${DIRINSTALL_DIR}/media/mirror" || true