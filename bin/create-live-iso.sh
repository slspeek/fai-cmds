#! /bin/bash
set -e

DESKTOP_ENVIRONMENT=$1
LANGUAGE=$2
FAI_CONFIG_DIR=$3
FAI_ETC=$4
BUILD_DIR=$5
TARGET_DIR="$BUILD_DIR/live-${DESKTOP_ENVIRONMENT}"

if [ -z "$DESKTOP_ENVIRONMENT" ] || [ -z "$LANGUAGE" ] || [ -z "$FAI_CONFIG_DIR" ] || [ -z "$FAI_ETC" ] || [ -z "$BUILD_DIR" ]; then
    echo "Usage: $0 <desktop_environment> <language> <fai_config_dir> <fai_etc> <build_dir>"
    exit 1
fi

cl_unexpanded="$(bin/get-classes-for-profile-name.sh $FAI_CONFIG_DIR $DESKTOP_ENVIRONMENT|sed -e 's/INSTALL,//'),${LANGUAGE},TRIXIE64,AMD64,STANDARD,TRIXIE,LIVEISO,LAST"
cl=$(bin/fai-deps-wrapper.sh $FAI_CONFIG_DIR "$cl_unexpanded")
HOSTNAME="live-${DESKTOP_ENVIRONMENT/ /-}"
echo -e "Installing FAI configuration for $HOSTNAME with\nclasses: $cl"
sudo mkdir -p "${TARGET_DIR}"
sudo LC_ALL=C fai -v -C ${FAI_ETC} dirinstall -u $HOSTNAME -c $cl  -s file://${FAI_CONFIG_DIR} "${TARGET_DIR}" || true

ISO_NAME="live-${DESKTOP_ENVIRONMENT}.iso"
echo "Creating ISO image: $ISO_NAME"
sudo fai-cd -s500 -MH -c $FAI_CONFIG_DIR -d none -g ${FAI_ETC}/grub.cfg.live -n "${TARGET_DIR}" "$BUILD_DIR/$ISO_NAME"