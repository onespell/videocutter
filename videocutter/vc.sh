#!/bin/sh

DIR=/path/to/videocutter

if [ $# == 1 ] ; then
	$DIR/vc.tcl "$1" &
	# $DIR/vc.tcl -report "$1" &
else
	$DIR/vc.tcl &
fi
