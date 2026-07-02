#!/bin/sh
set -eu

for device in /sys/bus/usb/devices/*; do
  [ -r "$device/idVendor" ] || continue
  [ -r "$device/idProduct" ] || continue
  [ -r "$device/product" ] || continue
  [ -w "$device/power/wakeup" ] || continue

  vendor="$(cat "$device/idVendor")"
  product_id="$(cat "$device/idProduct")"
  product="$(cat "$device/product")"

  if [ "$vendor" = "18d1" ] && [ "$product_id" = "5057" ] && [ "$product" = "Hammer" ]; then
    echo disabled >"$device/power/wakeup"
  fi
done
