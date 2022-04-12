#!/usr/bin/env python
# coding: utf-8

# <a href="https://colab.research.google.com/github/rennydoig/ssc22-case-comp/blob/main/Daisy_dir/Exploratory_Data_Analysis.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>

# In[ ]:


import pandas as pd
import numpy as np
import os
import csv
# get_ipython().system('pip install geopandas rtree')
import geopandas as gpd
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import seaborn as sns
## from google.colab import drive
## drive.mount('/content/drive')
## os.chdir('/content/drive/My Drive/2022 SSC Case Study')
## print(os.getcwd())


# In[ ]:


# Read data
# df = pd.read_csv("ookla-canada-speed-tiles.csv")

# Check data shape
# print("data shape:{shape}".format(shape=df.shape),"\n", "data columns:{columns}".format(columns=list(df.columns))) 


# In[ ]:


def makeData(df, aggregate_by, conType, value):
    """ Make an appropriate data frame for prediction """

    '''
    df: orginal data frame from SSC
    aggregate_by: 'quadkey' or 'DAUID' or 'CDNAME' or "PRNAME"
    conType: boolen, has the option to seperate connect type (e.g. fixed or mobile)
    value: 'avg_d_mbps' or 'avg_u_mbps' or 'avg_lat_ms'
    '''

    # Change kbps to mbps
    df['avg_d_mbps'] = df['avg_d_kbps'] / 1000
    df['avg_u_mbps'] = df['avg_u_kbps'] / 1000

    # Combine "year" and "quarter" and create a new column called "Date"
    df['Date'] = ["-".join(i) for i in zip(df['year'].astype(str), df['quarter'])]

    # Filter only rural areas: rows with NaN for either PCUID, PCNAME, PCTYPE, or PCCLASS
    cond = (df['PCUID'].isna()) | (df['PCNAME'].isna()) | (df['PCTYPE'].isna()) | (df['PCCLASS'].isna())
    df_rural = df[cond]
  
    # Aggregate data
    dat = dataAggregation(df_rural,aggregate_by,conType)

    # Transform the data: rows -> aggregate_by and columns -> Date
    if conType:
      output_data = dat.pivot_table(values=value,index=[aggregate_by],columns=['conn_type','Date'],aggfunc='mean')
    else:
      output_data = dat.pivot_table(values=value,index=[aggregate_by],columns=['Date'],aggfunc='mean')
    
    # Append 'tests' and 'DA_POP'
    if aggregate_by == "DAUID":
      output_data[['tests','DA_POP']] = dat.groupby(aggregate_by).agg({'tests':'sum','DA_POP':'mean'})
    else:
      output_data[['tests','DA_POP']] = dat.groupby(aggregate_by).agg({'tests':'sum','DA_POP':'sum'})
    return output_data


def dataAggregation(df, aggregate_by, conType):
    """ Aggregate data by tile, dissemination area, census division or province """

    # Weighted average of 'avg_d_mbps', 'avg_u_mbps' and 'avg_lat_ms', weight = 'tests'
    wm = lambda x: np.average(x, weights=df.loc[x.index, 'tests'])

    if conType:
      if aggregate_by == 'DAUID':
        dat = df.groupby([aggregate_by,'Date','conn_type'],as_index=False).agg({"avg_u_mbps":wm,
                                                                                "avg_d_mbps":wm,
                                                                                "avg_lat_ms":wm,
                                                                                "tests":"sum",
                                                                                "DA_POP":wm})
      else:
        dat = df.groupby([aggregate_by,'Date','conn_type'],as_index=False).agg({"avg_u_mbps":wm,
                                                                                "avg_d_mbps":wm,
                                                                                "avg_lat_ms":wm,
                                                                                "tests":"sum",
                                                                                "DA_POP":"sum"})
    else: 
      if aggregate_by == 'DAUID':
        dat = df.groupby([aggregate_by,'Date'],as_index=False).agg({"avg_u_mbps":wm,
                                                                    "avg_d_mbps":wm,
                                                                    "avg_lat_ms":wm,
                                                                    "tests":"sum",
                                                                    "DA_POP":wm})
      else:
        dat = df.groupby([aggregate_by,'Date'],as_index=False).agg({"avg_u_mbps":wm,
                                                                    "avg_d_mbps":wm,
                                                                    "avg_lat_ms":wm,
                                                                    "tests":"sum",
                                                                    "DA_POP":"sum"})
    return dat


# In[ ]:


# Final output data will look like
# dat = makeData(df, 'CDNAME', True, 'avg_d_mbps')
# dat

