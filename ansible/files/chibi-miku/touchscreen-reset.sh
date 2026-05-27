#!/bin/sh

if [ "${1}" = "post" ]; then
  DEV_ID="4-0001"
  DRIVER_PATH="/sys/bus/i2c/drivers/i2c_hid_of"

  echo "$DEV_ID" >"$DRIVER_PATH/unbind"
  sleep 0.1
  echo "$DEV_ID" >"$DRIVER_PATH/bind"
fi
