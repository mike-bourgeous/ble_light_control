#!/bin/bash
# Quick and dirty script to control Bluetooth Low Energy lights compatible with
# the Happy Lighting mobile app using gatttool from BlueZ.
#
# See the README for a list of references.
#
# (C)2020 Mike Bourgeous, released under standard 2-clause BSD license

DEVICE=$1

if [ $# != 1 ]; then
	echo "Usage: $0 address"
	echo "Device address must be specified in the form xx:xx:xx:xx:xx:xx"
	exit 1
fi

rgb()
{
	red=$1
	green=$2
	blue=$3

	printf "char-write-cmd 0x0007 56%02x%02x%02x00f0aa\n" $red $green $blue
}

light_script()
{
	trap "echo quit; echo quit; exit" SIGINT
	echo connect
	sleep 0.75
	for f in `seq 1 255`; do
		rgb $f 255 $((255 - $f))
		sleep 0.01
	done
	echo quit
}

light_script | gatttool -b "$DEVICE" -I | grep -i --line-buffered -E '(fail|error|discon)'
