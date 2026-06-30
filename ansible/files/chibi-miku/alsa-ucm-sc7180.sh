#!/bin/sh

HIFI=/usr/share/alsa/ucm2/Qualcomm/sc7180/rt5682-max98357a/HiFi.conf
PATCH=/etc/alsa/sc7180-no-headphones.patch

if [ -f "$HIFI" ] && { grep -q 'SectionDevice."Headphones"' "$HIFI" || grep -q 'SectionDevice."Headset"' "$HIFI"; }; then
    patch "$HIFI" "$PATCH"
fi
