#!/bin/sh

export QEMU_OPTS="-cpu host -smp 2 -m 4096M -machine type=q35,accel=kvm"
./result/bin/run-*
