#!/usr/bin/env python3

from subprocess import call
import os,sys
import numpy as np 
import json
import ruamel.yaml as yaml
import argparse
import pathlib
from scipy.interpolate import interp1d
import pandas as pd
import re
import matplotlib
import matplotlib.pyplot as plt
import importlib
import time
import glob

ofparamhome = os.environ.get('OPENFAST_PARAM')
sys.path.append(ofparamhome + '/import')
import plot_func as pf
importlib.reload(sys.modules['plot_func'])

def find_line(lookup,filename):
    linelist = []
    with open(filename) as myFile:
        for num, line in enumerate(myFile, 1):
            if lookup in line:
                linelist.append(num)
    return linelist

def get_bounds(data,time,azmin,azmax):
    tmax = np.max(time)
    dt = tmax/len(time)
    xmin = azmin - 20.0
    xmax = np.max(time)+5.0
    dplot = int(np.floor((tmax - xmin)/dt))
    ybmax = np.max(np.array(data[-dplot:-2]))
    ybmin = np.min(np.array(data[-dplot:-2]))
    ymin = ybmin-ybmin*0.08
    ymax = ybmax+ybmax*0.08
    if (ybmax < 0.2 and ybmin > -0.2):
        ymax = 0.2
        ymin = -0.2
    
    return xmin,xmax,ymin, ymax

def main():
    parser = argparse.ArgumentParser(description="Quickly plot and display openfast output")
    parser.add_argument(
        "-d",
        "--directory",
        help="Directory with wind speed cases",
        required=False,
        type=str,
        default="",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        help="Add prefix to outputfilename",
        required=False,
        type=str,
        default="",
    )

    args = parser.parse_args()

    case_list = glob.glob(args.directory + '/wind*')
    var_list = ['GenPwr','BldPitch1','RotSpeed','B1TipTDxr']

    ws = [float(c.split('_')[-1]) for c in case_list]
    sort_case_list = [x for _,x in sorted(zip(ws,case_list))]
    ws = sorted(ws)

    #fig, ax = plt.subplots(len(case_list),len(var_list),figsize=(12,8))
    fig = plt.figure(constrained_layout=True,figsize=(12,8))
    subfigs = fig.subfigures(nrows=len(sort_case_list), ncols=1)

    

    for i,c in enumerate(sort_case_list):

        print('Processing: ',c)

        yaml_inp = c + '/inp.yaml'

        # Read YAML file
        with open(yaml_inp, 'r') as stream:
            inp_loaded = yaml.safe_load(stream)

        azblend = inp_loaded['Turbine0']['az_blend_mean']
        azblenddel = inp_loaded['Turbine0']['az_blend_delta']
        precursor_end = float(inp_loaded['t_end'])

        # Load openfast data
        tc = "cat " + c + "/IEA-15-240-RWT-Monopile.out | awk 'length($0) > 1000' > " + c + "/trimmed.out"
        #print(tc)
        os.system(tc)
        openfast_file = c + '/trimmed.out'
        #openfast_file = c + '/IEA-15-240-RWT-Monopile.out'

        headskip = [1]
        for s in find_line('#Restarting here',openfast_file):
            #print("Appending")
            headskip.append(s-1)
        #print(headskip)
        this_data = pd.read_csv(openfast_file,sep='\s+',skiprows=(headskip), header=(0),skipinitialspace=True, dtype=float)
        #print('Length:',(list(this_data.keys())))
        #print(list(this_data.keys()))


        approx_azblend = azblend/(np.array(this_data.RotSpeed)[1]*2*np.pi/60.0)
        approx_azblendmin = (azblend-(azblenddel/2))/(np.array(this_data.RotSpeed)[1]*2*np.pi/60.0)
        approx_azblendmax = (azblend+(azblenddel/2))/(np.array(this_data.RotSpeed)[1]*2*np.pi/60.0)
        #print(np.array(np.array(this_data.RotSpeed)[0]*2*np.pi/60.0))
        #print(approx_azblend)

        subfigs[i].suptitle(str(ws[i])+' m/s')
        ax = subfigs[i].subplots(nrows=1, ncols=len(var_list))

        for j,v in enumerate(var_list):

            xmin,xmax,ymin,ymax = get_bounds(this_data[v],this_data['Time'],approx_azblendmin,approx_azblendmax)
            #yb_min = np.min(np.array(this_data[v]))
            ax[j].plot(this_data['Time'], this_data[v], label=v)
            if(i==0):
                ax[j].set_title(v)
            ax[j].set_xlabel("Time [s]") 
            ax[j].set_xlim([xmin,xmax]) 
            ax[j].set_ylim([ymin,ymax])
            #ax[j].set_ylabel(v)
            ax[j].axvline(precursor_end, ymin=0, ymax=1,c="red",linestyle="--")
            ax[j].axvline(approx_azblend, ymin=0, ymax=1,c="green")
            ax[j].axvline(approx_azblendmin, ymin=0, ymax=1,c="green",linestyle="--")
            ax[j].axvline(approx_azblendmax, ymin=0, ymax=1,c="green",linestyle="--")
    plt.savefig(args.prefix + '_all.png')
    plt.close()

if __name__ == "__main__":
    main()