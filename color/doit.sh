#!/bin/sh

DRIVE=$1

yes | ./rootimg/make_bootable_usb.sh $DRIVE ./out/bootimg/pixel2_kernel.bin ./out/root/x86_64-fuchsia-linux-musl
./color/fix_init.sh $DRIVE
./color/mkdata.sh $DRIVE
