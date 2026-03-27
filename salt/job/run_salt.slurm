#!/bin/bash --login
#SBATCH --job-name=salt_job
#SBATCH --output=salt_job.out
#SBATCH --error=salt_job.err
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
#SBATCH --gpus=a100:1

module purge
module load Miniforge3

conda activate salt
cd /mnt/home/qianron1/research/salt/

# Step 4: Run your actual code
salt fit --config /mnt/home/qianron1/research/salt/salt/configs/tttt_BSM_Run3_ttZp_v2/fold0.yaml