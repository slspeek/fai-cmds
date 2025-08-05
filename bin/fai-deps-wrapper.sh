#! /bin/bash
set -e

FAI_CONFIG_DIR=$1
CLASSES=$2


temp_log_dir=$(mktemp -d)
 (echo $CLASSES|tr ',' '\n') > ${temp_log_dir}/FAI_CLASSES
(export FAI=$FAI_CONFIG_DIR; export LOGDIR=$temp_log_dir; fai-deps)
cat ${temp_log_dir}/FAI_CLASSES|tr '\n' ','| sed 's/,$//'
rm -rf ${temp_log_dir}