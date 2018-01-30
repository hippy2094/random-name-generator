#!/bin/sh

fpcbin=fpc
fpctarget=`$fpcbin -iTP`-`$fpcbin -iTO`
libpath='./lib/'$fpctarget

if [ ! -d $libpath ]; then
  mkdir -p $libpath
fi

$fpcbin @extrafpc.cfg randomnamegen.pas

