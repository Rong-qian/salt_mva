setupATLAS
source setup/setup_conda.sh
conda activate salt
python -m pip install -e . --no-cache-dir
pip install -r requirements.txt


