#!/bin/bash --login
#SBATCH --job-name=salt_eval
#SBATCH --output=salt_eval.out
#SBATCH --error=salt_eval.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4           # adjust based on your script
#SBATCH --mem-per-cpu=16G           # 16 GB per CPU × 4 CPUs = 64 GB total#SBATCH --cpus-per-task=1
#SBATCH --gpus=a100:1

module purge
module load Miniforge3

conda activate salt
cd /mnt/home/qianron1/Documents/research/salt/

# Step 4: Run your actual code
python3 scripts/onnx.py

