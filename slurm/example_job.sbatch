#!/bin/sh
#SBATCH --time=00:05:00
#SBATCH --mail-type=NONE

case $MODE in
    'stress')
        srun stress -c 1 -t 180
    ;;
    'sleep')
        srun sleep 120
    ;;
    'timeout')
        srun sleep 100000
    ;;
    *)
         exit 1
    ;;
esac
