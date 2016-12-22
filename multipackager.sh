#!/bin/bash

rm -rf install
mkdir -p install
cd install
GTK_VERSION=`pkg-config --modversion gtk+-3.0`
echo $GTK_VERSION
if [ "$GTK_VERSION" \< "3.22" ];
then
	cmake .. -DGTK_3_20=on
else
	cmake ..
fi
make
make DESTDIR=$1 PREFIX=/usr install
