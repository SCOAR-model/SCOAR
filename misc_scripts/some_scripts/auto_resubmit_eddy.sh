#!/bin/bash
set -ax
#$ -S /bin/bash
##$ -l h_rt=24:00:00,num_proc=12
#$ -q short.q
#$ -w e
##$ -R no
#$ -N resubmit_tesnt
#$ -pe mpi 120
#$ -P seo_def
##$ -m aeb
##$ -M hseo@whoi.edu
#$ -cwd
##$ -v LD_LIBRARY_PATH
#$ -v MPI_HOME

set -ax
RUN_TIME=0:1:0 #DD:HH::MM
restart_interval=1440 # write wrfrst file each day
restart_interval=60 # write wrfrst file each day

# number of resubmit
YYYYi=0001
MMi=01
DDi=01
HHi=00

Resubmit_number=365
num=1

util_dir=/scratch/h/hseo/WRF_ROMS/Lib/utils
curr_dir=/mara/scratch/hseo/WRF_ROMS/Model/WRF30/b_wave/1km/bwave_runs/test
work_dir=/mara/scratch/hseo/WRF_ROMS/Model/WRF30/b_wave/1km/bwave_runs/test/em_b_wave_eddy

# this file contains the number of resubmission you want 
RESTART_REMAINING=$curr_dir/.remaining
echo $Resubmit_number > $RESTART_REMAINING

# this file contains the current number of restarting runs.
RESTART_CURRENT=$curr_dir/.current
echo $num > $RESTART_CURRENT

if [ -f $RESTART_REMAINING ]; then
    read N < $RESTART_REMAINING
    echo "N=$N"
    echo "file resubmit exists and requests $N more job submissions"

    if [ $N -gt 0 ]; then
      RESUBMIT=TRUE
      export RESUBMIT
      N=`expr $N - 1`
      rm $RESTART_REMAINING
      echo $N > $RESTART_REMAINING
    else
	echo "last submission.."
      RESUBMIT=FALSE
      export RESUBMIT
    fi
fi

if [ $RESUBMIT = TRUE ]; then
        read num < $RESTART_CURRENT || exit 8
        echo "num=" $num

	if [ $num -eq 1 ]; then
		WRF_RESTART=.false.
	else
		WRF_RESTART=.true.
	fi

	$curr_dir/changenamelistinput.sh $RUN_TIME $YYYYi:$MMi:$DDi:$HHi $WRF_RESTART $restart_interval || exit 8
	cp $curr_dir/namelist.input $work_dir

	cd $work_dir
	$work_dir/sub_wrf_auto.sh $work_dir $num
	cd $curr_dir

	# next 24 hours
	$util_dir/incdte $YYYYi $MMi $DDi $HHi 01 > incdte$$ || exit 8
        read YYYYi MMi DDi HHi < incdte$$ ; rm incdte$$
	num=`expr $num + 1`

	qsub auto_resubmit_eddy.sh
	num=`expr $num + 1 `
	echo $num > $RESTART_CURRENT
else
	echo "job done"
fi
