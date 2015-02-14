#!/bin/bash

PROGRAM="$1"
SH="./$PROGRAM.sh"
BIN="/tmp/$PROGRAM.bin"
DEV="/dev/mmcblk0"
chmod +x $SH
$SH > $BIN
dd if=$BIN of=$DEV

