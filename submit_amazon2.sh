#!/bin/bash
#SBATCH --job-name=aww3# Job name
##SBATCH --mail-type=all 
##SBATCH --mail-user=hseo@whoi.edu
##SBATCH --ntasks=24                  # Number of MPI ranks
##SBATCH --cpus-per-task=1            # Number of cores per MPI rank 
#SBATCH --nodes=1                    # Number of nodes
#SBATCH -n 36
#SBATCH --ntasks-per-node=36         # How many tasks on each node
##SBATCH --distribution=cyclic:cyclic # Distribute tasks cyclically on nodes and sockets
#SBATCH --mem=192000          # Memory per processor
#SBATCH --time=03:00:00              # Time limit hrs:min:sec
##SBATCH --output=scoar_%j.log     # Standard output and error log
#pwd; hostname; date
#SBATCH -p scavenger
#SBATCH --qos=scavenger
##SBATCH -x pn[057-072],pn[120-129],pn[97-100]
#SBATCH -x pn[097-100]
##SBATCH —-no-requeue

module purge ; module load stack/impi/1.0 default-environment ncview nco
curr_dir=/vortexfs1/share/seolab/SCOAR2_share/scoar_ww3
$curr_dir/amazon2_ww3.sh >& amazon_ww3_log01
