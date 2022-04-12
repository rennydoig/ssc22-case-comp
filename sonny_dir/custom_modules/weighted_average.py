import geopandas as gpd
import pandas as pd
import numpy as np
import rtree
#import os
#import pickle
#import matplotlib.pyplot as plt


def flatten_list(l):
    result = []
    for ii in l:
        if type(ii) == str:
            result.append(ii)
        else:
            try:
                for i in ii:
                    result.append(i)
            except TypeError:
                break
    return result


def w_avg(df, group_col, to_avg, to_sum = None, weight='tests'):
    """ Computes weighted averages of specified columns"""
    '''
    df: target data frame.
    group_col: String. The grouping column.
    to_avg: list of columns to perform weighted average. 
    to_sum: list of columns to perform weighted sum.
    weight: String. Name of the column that is used for weighting the averages. 'tests' or 'devices'

    e.g., w_avg(df, group_col = 'CDUID', to_avg = ['avg_d_mbps', 'avg_u_mbps', 'avg_lat_ms', 'SACTYPE'], to_sum = ['DA_POP'], weight='tests')

    '''
    
    groups = df[group_col].unique() 
    input_cols = [group_col, to_avg, to_sum, weight]
    result_cols = flatten_list(input_cols)
    result_df = pd.DataFrame(columns = result_cols)
    df = df.replace(np.nan, 1)

    for i, group in enumerate(groups): # for each ID
        
        # extract a group
        temp_table = df[df[group_col]==group].copy()
        temp_weight = temp_table[weight] / np.sum(temp_table[weight]) # compute the weights

        new_row = [group]

        # compute the weighted averages:
        for a_col in to_avg:              
            if temp_table[a_col].dtype == 'O':
                temp_table.loc[:,a_col] = pd.to_numeric(df[a_col])
            temp_avg = np.average(temp_table[a_col], weights = temp_table[weight])
            new_row.append(temp_avg)
        
        # compute the weighted sum:
        for s_col in to_sum:
            if temp_table[s_col].dtype == 'O':
                temp_table.loc[:,s_col] = pd.to_numeric(df[s_col])
            temp_sum = np.dot(temp_table[s_col], temp_weight)
            new_row.append(temp_sum)
        new_row.append(np.sum(temp_table[weight]))
        
        # append the averaged value to the result dataframe
        result_df.loc[i] = new_row
        
    return result_df

def gen_w_avg(df, group_col, to_avg, to_sum, weight='tests'):
    
    crs = df.crs
    prs = df.loc[:, 'PRUID'].unique()
    prnames = df.loc[:, 'PRNAME'].unique()
    years = df.loc[:,'year'].unique()
    quarters = df.loc[:,'quarter'].unique()
    conn_types = df.loc[:,'conn_type'].unique()
    new_cols = flatten_list(['PRUID', group_col, to_avg, to_sum, weight, 'geometry'])
    avg_table = pd.DataFrame(columns = new_cols)

    for i,pr in enumerate(prs):
        for year in years:
            for quarter in quarters:
            
                print('Processing: {pr}-{year}-{quarter}'.format(pr=prnames[i], year=year, quarter=quarter))
                
                for c_type in conn_types:
                    idx = (df['PRUID'] == pr) & (df['year'] == year) & (df['quarter'] == quarter) & (df['conn_type'] == c_type)
                    temp_table = df.loc[idx,:]
                    temp_avgs = w_avg(temp_table, group_col=group_col, to_avg = to_avg, to_sum = to_sum, weight = weight)
                    
                    temp_polygon_df = temp_table.loc[:, [group_col, 'geometry']]
                    temp_polygon_dissolve = temp_polygon_df.dissolve(by=group_col)

                    temp_combined = pd.merge(temp_avgs, temp_polygon_dissolve, on = group_col, how = 'left')
                    temp_combined['conn_type'] = c_type
                    temp_combined['time'] = str(year) + '-' + str(quarter)
                    temp_combined['PRUID'] = pr

                    avg_table = pd.concat([avg_table, temp_combined])
    
    # convert kbps to mbps:
    try:
        avg_table['avg_d_mbps'] = avg_table.loc[:,'avg_d_kbps'] / 1000
        avg_table['avg_u_mbps'] = avg_table.loc[:,'avg_u_kbps'] / 1000
        avg_table = avg_table.drop(columns = ['avg_d_kbps', 'avg_u_kbps'])
    except:
        break
    gpd_table = gpd.GeoDataFrame(avg_table, geometry='geometry', crs = crs)
    #gpd_table = gpd_table.to_crs('EPSG:3347') # statistics canada lambert

    return gpd_table

def get_dest_df(df, dest_col='PCUID', fillna='0000', centroid = 'centroid'):
    temp_df = df.copy()
    temp_df[dest_col] = temp_df.loc[:, dest_col].fillna(fillna)
    dest_df = temp_df.loc[temp_df[dest_col]!= fillna, centroid]
    return dest_df
