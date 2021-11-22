#!/bin/bash

if [[ "$1" =~ ^[0-2][0-9]:[0-6][0-9]$ ]] ; then
	echo si
else
	echo no
fi
