import geopandas as gpd
import pandas as pd
import numpy as np
import rtree
import os
import pickle
# import matplotlib.pyplot as plt
from joblib import Parallel, delayed
import sys
import weighted_average as WA

# load canada data


with open('../../dataset/python_canada-speed-data.p', 'rb') as file:
    can_data = pickle.load(file)

print('data load complete')

test_idx = np.random.randint(0, len(can_data), size=1000)
can_dat = can_data.loc[test_idx, :]

# obtain the list of Province ID's
prs = can_dat.loc[:,'PRUID'].unique()

# Define processing job
def pr_job(pr):
    df = can_dat.loc[can_dat['PRUID'] == pr, :].copy()
    df['centroid'] = df.loc[:, 'geometry'].centroid
    df['distance'] = 0
    
    dest_df = WA.get_dest_df(df, dest_col = 'PCUID')

    for i in range(0, df.shape[0]): # takes about 20 mins
        temp_row = df.loc[i, 'centroid']
        df.loc[i, 'distance'] = np.min(dest_df.distance(temp_row)) / 1000

    result = WA.gen_w_avg(df, group_col='CDUID', to_avg = ['avg_d_kbps', 'avg_u_kbps', 'avg_lat_ms', 'SACTYPE', 'distance'], to_sum = ['DA_POP'], weight='tests')
    return result

# run parallel processing

# pd.concat(Parallel(n_jobs=-2)(delayed(pr_job)(pr) for pr in prs))
def parallel_df(prs):
    pr_df = pd.concat(Parallel(n_jobs=-2)(delayed(pr_job)(pr) for pr in prs))
    result_df = pd.concat(pr_df)

    return result_df

parallel_df(prs)

