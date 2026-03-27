import argparse
import subprocess
import tempfile
import os

def generate_and_submit_slurm(config_path, job_name):
    output_file = f"{job_name}.out"
    error_file = f"{job_name}.err"

    slurm_script = f"""#!/bin/bash --login
#SBATCH --job-name={job_name}
#SBATCH --output={output_file}
#SBATCH --error={error_file}
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
#SBATCH --gpus=a100:1

module purge
module load Miniforge3

conda activate salt
cd /mnt/home/qianron1/Documents/research/salt/

salt fit --config {config_path}
"""

    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=".slurm") as f:
        f.write(slurm_script)
        script_path = f.name

    try:
        result = subprocess.run(['sbatch', script_path], check=True, capture_output=True, text=True)
        print("Job submitted successfully:")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("Failed to submit job:")
        print(e.stderr)
    finally:
        os.remove(script_path)

def main():
    parser = argparse.ArgumentParser(description="Submit a SLURM job to run salt fit.")
    parser.add_argument('--config', required=True, help="Path to the SALT config file")
    parser.add_argument('--name', required=True, help="Job name (used for job ID, .out, and .err files)")

    args = parser.parse_args()
    generate_and_submit_slurm(args.config, args.name)

if __name__ == '__main__':
    main()