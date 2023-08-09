#!/bin/bash
set -e

output=$(husarnet-dds singleshot) || true
if [[ "$HUSARNET_DDS_DEBUG" == "TRUE" ]]; then
  echo "$output"
fi

if [ -z "${XRCE_DOMAIN_ID_OVERRIDE}" ]; then
  if [ -n "${ROS_DOMAIN_ID}" ]; then
    export XRCE_DOMAIN_ID_OVERRIDE="${ROS_DOMAIN_ID}"
  fi
fi


exec "$@"