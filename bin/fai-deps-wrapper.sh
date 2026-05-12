#! /bin/bash
set -e

fai_config_dir=$1
classes=$2
if [[ -z $fai_config_dir || -z $classes ]]; then
    echo "Usage: $0 <fai_config_dir> <classes>"
    exit 1
fi

temp_log_dir=$(mktemp -d)
(echo "$classes" | tr ',' '\n') > "${temp_log_dir}/FAI_CLASSES"
(export FAI="$fai_config_dir"; export LOGDIR="$temp_log_dir"; fai-deps)
cat "${temp_log_dir}/FAI_CLASSES" | tr '\n' ',' | sed 's/,$//'
rm -rf "${temp_log_dir}"