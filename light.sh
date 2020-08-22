#!/bin/bash
# Quick and dirty script to control Bluetooth Low Energy lights compatible with
# the Happy Lighting mobile app using gatttool from BlueZ.
#
# See the README for a list of references.
#
# (C)2020 Mike Bourgeous, released under standard 2-clause BSD license

DEVICE=$1
ARGC=$#

if [ $ARGC -ne 1 -a $ARGC -ne 2 -a $ARGC -ne 4 ]; then
	echo "Usage: $0 address [w|r g b]"
	echo "Device address must be specified in the form xx:xx:xx:xx:xx:xx"
	exit 1
fi

# TODO: Support color effect modes and setting timers

white()
{
	white=$1
	printf "char-write-cmd 0x0007 56000000%02x0faa\n" $white
}

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
	sleep 0.75 # TODO: this should wait for the connection success message

	case $ARGC in
		1)
			echo "Color fade test" >&2
			for f in `seq 1 255`; do
				rgb $f 255 $((255 - $f))
				sleep 0.01
			done
			;;

		2)
			echo "White light at $1" >&2
			white $1
			sleep 0.1
			;;

		4)
			echo "RGB light at $1, $2, $3" >&2
			rgb $1 $2 $3
			sleep 0.1
			;;
	esac

	echo quit
}

shift
light_script "$@" | gatttool -b "$DEVICE" -I | grep -i --line-buffered -E '(fail|error|discon)'
