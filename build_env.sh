source setup/setup_conda.sh
conda create -n salt python=3.10
conda activate salt
conda install jsonnet
conda install chardet
conda install uproot

python -m pip install -e . --no-cache-dir

python -m pip install pandas  --no-cache-dir
conda install pytables 
pip install -r requirements.txt --no-cache-dir
