#!/bin/bash

DRIVE=$1

mount ${DRIVE}3 usb
cp -a color/data/* usb/
chown -R root:root usb/*
umount usb
