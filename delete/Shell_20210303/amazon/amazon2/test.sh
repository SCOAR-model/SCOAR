#!/bin/sh
set -ax
NHour=1289
if [ $NHour -lt 10 ]; then
ROMS_Output_time=0000$NHour
fi

if [ $NHour -gt 10  -a $NHour -lt 100 ]; then
ROMS_Output_time=000$NHour
fi

if [ $NHour -gt 100  -a $NHour -lt 1000 ]; then
ROMS_Output_time=00$NHour
fi

if [ $NHour -gt 1000  -a $NHour -lt 10000 ]; then
ROMS_Output_time=0$NHour
fi

