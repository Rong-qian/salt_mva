import h5py
import pandas as pd
import glob
import numpy as np
pd.set_option('display.max_columns', 500)
pd.set_option('display.float_format', '{:.8f}'.format)

filename="logs/v3p0_ttZp_v02_00_0001_fold0_20240310-T174721/ckpts/epoch=000-val_loss=0.55001__test_ttHH_bkg.h5"
f = h5py.File(filename, "r")
print(f.keys())
df = f['tracks'][:]
print(df.dtype.names)
print(df[15])

