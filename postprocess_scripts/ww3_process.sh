#!/bin/bash
#SBATCH --job-name=r02ww3# Job name
##SBATCH --mail-type=all
##SBATCH --mail-user=hseo@whoi.edu
##SBATCH --ntasks=24                  # Number of MPI ranks
##SBATCH --cpus-per-task=1            # Number of cores per MPI rank
#SBATCH --nodes=1                    # Number of nodes
#SBATCH -n 1
#SBATCH --ntasks-per-node=36         # How many tasks on each node
##SBATCH --distribution=cyclic:cyclic # Distribute tasks cyclically on nodes and sockets
#SBATCH --mem=192000          # Memory per processor
#SBATCH --time=03:00:00              # Time limit hrs:min:sec
##SBATCH --output=scoar_%j.log     # Standard output and error log
#pwd; hostname; date
#SBATCH -p scavenger
#SBATCH --qos=scavenger

set -ax
export run_name=wfp_r02
echo $run_name
export DT=1

for domain in d02
do

YYYY=2018
MM=02
DD=01
HH=00

YYYYS=$YYYY
MONS=$MM
MON=$MONS
MONE=02
# last time should be "one more day" after the last time-step
last_time=2018-03-01_00

####
dirw=./$YYYY
mkdir -p $dirw

while [ $MON -le $MONE ]; do

MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then 
MON=0$MON
fi

# 1h
#just concatenate everything
filer=../Outnc/$YYYY/ww3.$YYYY$MON????_Hour*.nc
filew=$dirw/ww3_$domain\_$run_name\_$DT\h\_$YYYY$MON\.nc
ncecat -O $filer $filew || exit 8

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON

# daily averaging
tindx=$YYYY-$MM\-$DD\_$HH
while [ "$tindx" !=  "$last_time" ]; do
echo $tindx

filer=../Outnc/$YYYY/ww3.$YYYY$MM$DD??_Hour*.nc
filew=$dirw/ww3_$domain\_$run_name\_1d_$tindx\.nc
ncra -O $filer $filew || exit 8

incdte $YYYY $MM $DD $HH 24 >& incdte.$$ # increase by day
read YYYY MM DD HH < incdte.$$; rm incdte.$$

tindx=$YYYY\-$MM\-$DD\_00
done # tindx

# concatenate each month
MON=$MONS
while [ $MON -le $MONE ]; do
MON=`expr $MON + 0`
if [ $MON -lt 10 ]; then
MON=0$MON
fi
ncrcat -O $dirw/ww3_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc $dirw/ww3_$run_name\_1d_$YYYYS$MON\.nc || exit 8

# monthly averaging
ncra -O $dirw/ww3_$domain\_$run_name\_1d_$YYYYS$MON\.nc $dirw/ww3_$run_name\_1m_$YYYYS$MON\.nc || exit 8

# cleanup
rm $dirw/ww3_$domain\_$run_name\_1d_$YYYYS-$MON-??_00.nc

MON=`expr $MON + 0`
MON=`expr $MON + 1`
done # MON
done #domain

echo "DONE"
