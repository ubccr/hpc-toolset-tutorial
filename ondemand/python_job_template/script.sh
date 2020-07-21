#!/bin/bash

#SBATCH --job-name=python_script
#SBATCH --time=01:00:00
#SBATCH -n 1

#   A Basic Python Serial Job

#
# The following lines set up the Python environment
#
source /usr/local/jupyter/2.1.4/bin/activate

#
# Move to the directory where the job was submitted from
# You could also 'cd' directly to your working directory
cd $SLURM_SUBMIT_DIR

#
# Run Python
#
python hello.py
