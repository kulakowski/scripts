#!/bin/sh

DRIVE=$1

mount ${DRIVE}2 usb
umount usb
