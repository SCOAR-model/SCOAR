#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=nep1_r01                   # Job name
#SBATCH --mail-type=END                       # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=<your.email@whoi.edu>     # Where to send mail
#SBATCH --ntasks=144                          # Number of MPI ranks
#SBATCH --cpus-per-task=1                     # Number of cores per MPI rank
#SBATCH --nodes=4                             # Number of nodes                        #
#SBATCH --ntasks-per-node=36                  # How many tasks on each node
#SBATCH --ntasks-per-socket=18                # How many tasks on each CPU or socket
#SBATCH --distribution=cyclic:cyclic          # Distribute tasks cyclically on nodes & sockets
#SBATCH --mem-per-cpu=4gb                     # Memory per processor
#SBATCH --mem=150gb                           # Job Memory
#SBATCH --time=24:00:00                       # Time limit hrs:min:sec
#SBATCH --output=%j_slurm.log                 # Standard output/error
#SBATCH --no-requeue

scoar_dir=/vortexfs1/share/seolab/crenkl/models/SCOAR/main_scripts/example/example1
Couple_Run_Dir=/vortexfs1/share/seolab/crenkl/models/SCOAR/Run/example/example1/r01
read LastNHour < $Couple_Run_Dir/restart_info
export RESTART=yes

yyyye=2014
mme=11
dde=21
hhe=00

$scoar_dir/main_nep1_r01.sh $yyyye:$mme:$dde:$hhe $RESTART $LastNHour >& r01_log_$$_$yyyye$mme$dde$hhe
