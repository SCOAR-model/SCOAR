#!/bin/bash
#SBATCH --job-name=wsoc01# Job name
##SBATCH --mail-type=END,FAIL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=email@ufl.edu    # Where to send mail      
##SBATCH --ntasks=24                  # Number of MPI ranks
##SBATCH --cpus-per-task=1            # Number of cores per MPI rank 
#SBATCH --nodes=1                    # Number of nodes
#SBATCH -n 1
#SBATCH --ntasks-per-node=36         # How many tasks on each node
##SBATCH --ntasks-per-socket=6        # How many tasks on each CPU or socket
##SBATCH --distribution=cyclic:cyclic # Distribute tasks cyclically on nodes and sockets
#SBATCH --mem=192000          # Memory per processor
#SBATCH --time=24:00:00              # Time limit hrs:min:sec
#SBATCH --output=scoar_%j.log     # Standard output and error log
#SBATCH -p scavenger
#SBATCH --qos=scavenger
#pwd; hostname; date

curr_dir=/vortexfs1/share/seolab/hseo/SCOAR2/Run/miso/miso6/miso6_r01/Data/WRF/process
$curr_dir/make_6h_1d_1m_2019.sh >& log01
