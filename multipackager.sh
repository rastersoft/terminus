#!/bin/bash

rm -rf install
mkdir -p install
cd install
GTK_VERSION=`pkg-config --modversion gtk+-3.0`
echo $GTK_VERSION
if [ "$GTK_VERSION" \< "3.22" ];
then
	cmake .. -DGTK_3_20=on -DCMAKE_INSTALL_PREFIX=/usr
else
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr
fi
make VERBOSE=1
make DESTDIR=$1 install
