#!/bin/sh
INCLUDEDIR=/vortexfs1/apps/pgi/linux86-64/2018/netcdf/netcdf-4.5.0/openmpi-2.1.2/include
LIBDIR=/vortexfs1/apps/pgi/linux86-64/2018/netcdf/netcdf-4.5.0/openmpi-2.1.2/lib

##
#echo "write_wpsformat.f"
#pgf90 write_wpsformat.f -o write_wpsformat.x -byteswapio
###
#echo "read_ncvar.f"
#pgf90 -c -I$INCLUDEDIR read_ncvar.f
#pgf90 -o read_ncvar.x read_ncvar.o -L$LIBDIR -lnetcdf
###

echo "inchour.f"
pgf90 inchour.f -o inchour.x
###
echo "incdte.f"
pgf90 incdte.f -o incdte.x

###
####
rm -f *.o 2>/dev/null
if [ $? -eq 0 ]; then
echo "compiled and copied exectuables"
else
echo " compile failed!"
fi
