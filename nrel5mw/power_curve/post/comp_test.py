#!/usr/bin/env python3

from subprocess import call
import os,sys
import numpy as np 
import argparse
import pathlib
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt


# Shows single plot
def saveplotone(fig, axis, filepath, ls=1.5, fs=20):
    import matplotlib.pyplot as plt
    plt.rcParams.update({'font.size': fs})
    #### Get handles and print plot ####
    handles, labels = axis.get_legend_handles_labels()
    fig.legend(handles, labels, bbox_to_anchor=(ls, 0.8),frameon=False,prop={'size': fs})
    #axis.grid(b=True, which='major', color='#999999', linestyle='-', alpha=0.5)
    #axis.minorticks_on()
    #axis.grid(b=True, which='minor', color='#999999', linestyle='-', alpha=0.1)
    #for tick in axis.get_xticklabels():
    #    tick.set_fontname("Open Sans")
    #for tick in axis.get_yticklabels():
    #    tick.set_fontname("Open Sans")
    fig.tight_layout()
    plt.savefig(filepath, bbox_inches='tight')

def main():
    
    # Parse arguments
    parser = argparse.ArgumentParser(description="Quickly plot and display openfast output")
    parser.add_argument(
        "-v",
        "--variable",
        help="Variable to plot",
        required=True,
        type=str,
    )
    parser.add_argument(
        "-i1",
        "--infile1",
        help="Root name of file 1 (must be present in the case-input directory",
        required=True,
        type=str,
    )
    parser.add_argument(
        "-i2",
        "--infile2",
        help="Root name of file 2 (must be present in the case-input directory",
        required=True,
        type=str,
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
    infile1 = args.infile1
    infile2 = args.infile2

    if(args.variable == "report"):
        var = ["GenPwr","BldPitch1","RotSpeed","B1RootMxr"]
    else:
        var = [args.variable]

    headskip = [0,1,2,3,4,5,7]
    this_data1 = pd.read_csv(infile1,sep='\s+',skiprows=(headskip), header=(0),skipinitialspace=True)
    this_data2 = pd.read_csv(infile2,sep='\s+',skiprows=(headskip), header=(0),skipinitialspace=True)

    #print(list(this_data1.keys()))

    fig, ax = plt.subplots(len(var),1,figsize=(8,6))

    for i,v in enumerate(var):
        ax[i].plot(this_data1['Time'], this_data1[v], label="Run 1")
        ax[i].plot(this_data2['Time'], this_data2[v], label="Run 2")
        #ax.set_title(var)
        ax[i].set_xlabel("Time [s]") 
        ax[i].set_ylabel(v)

    saveplotone(fig, ax[0], args.prefix + '_' +args.variable+'.png', 1.23, 22)
    plt.close()

if __name__ == "__main__":
    main()