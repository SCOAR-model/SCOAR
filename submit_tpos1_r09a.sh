#!/bin/bash
#SBATCH -J r09a
#SBATCH -t 12:00:00
#SBATCH -o accounting/slurm-%j.out
#SBATCH --ntasks=144
#SBATCH -A s2634
##SBATCH --qos=high
##SBATCH --mail-user=user@nasa.gov

#export Couple_Run_Dir=$PROJECT/hseo4/Git/wrf-ww3-ustar-working/SCOAR2/Run/$gridname2/$gridname/$RUN_ID
export Couple_Run_Dir=$PROJECT/hseo4/Git/wrf-ww3-ustar-working/SCOAR2/Run/tpos/tpos1/r09/
if [ -s $Couple_Run_Dir ]; then
read LastNHour < $Couple_Run_Dir/restart_info
fi
export RESTART=no

yyyye=2020
mme=01
dde=15
hhe=00

./tpos1_r09_restart.sh $yyyye:$mme:$dde:$hhe $RESTART $LastNHour >& r09_log_$$_$yyyye$mme$dde

#./tpos1_r09_restart.sh 2020:01:30:00 yes 12 
#>& out
