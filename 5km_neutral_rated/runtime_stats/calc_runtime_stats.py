# -*- coding: utf-8 -*-
""" Calculate relevant quantities from statistics of precursor ABL-LES
for inflow/outflow simulation
"""

import sys
from pathlib import Path
import argparse, textwrap
import numpy as np
import netCDF4 as nc

boundary_planes = '../boundary_plane/post_processing/abl_statistics30000.nc'

class ABLInflowOutflowPrep:
    """Prep inputs for Inflow/Outflow simulation"""

    def __init__(self):
        """
        Args:
            stats_file (path): Path to the file containing statistics during
                               time of interest
            t_start (float): Start time of inflow/outflow simulation
            t_end (float): End time of inflow/outflow simulation
        """
        self.stats_file = boundary_planes
        self.dset = nc.Dataset(Path(self.stats_file))
        self.t_start = 15000
        self.t_end = 16000

    def calc_runtime_stats(self):
        """Examine statistics file and calculate relevant quantities """

        time = self.dset['time'][:]
        t_filter = (time > self.t_start) & (time < self.t_end)

        if (not t_filter.any()):
            dset_tstart = time[0]
            dset_tend = time[-1]
            sys.exit(textwrap.dedent(f"""
            Statistics file time window does not cover desired run time of inflow outflow simulation

            Desired start time   = {str(self.t_start)}
            Desired end time     = {str(self.t_end)}

            Time window in statistics file = {str(dset_tstart)} - {str(dset_tend)}
            """))

        abl_force_x = np.average(self.dset['abl_forcing_x'][t_filter])
        abl_force_y = np.average(self.dset['abl_forcing_y'][t_filter])

        mean_profiles = self.dset['mean_profiles']
        hvelmag = np.average(mean_profiles['hvelmag'][t_filter, 0])
        u_prof = mean_profiles['u'][t_filter, :]
        u_mean = np.average(mean_profiles['u'][t_filter, 0])
        v_mean = np.average(mean_profiles['v'][t_filter, 0])
        theta_mean = np.average(mean_profiles['theta'][t_filter, 0])

        h = self.dset['mean_profiles']['h'][:]
        avg_theta = np.average(mean_profiles['theta'][t_filter, :], 0)
        with open('avg_theta.dat','w') as f:
            f.write('{} \n'.format(avg_theta.size))
            for i,t in enumerate(avg_theta):
                f.write('{} {} \n'.format(h[i], t))

        print(textwrap.dedent(f"""
        Statistics file      = {self.stats_file}
        Desired start time   = {str(self.t_start)}
        Desired end time     = {str(self.t_end)}
        abl_forcing_x        = {str(abl_force_x)}
        abl_forcing_y        = {str(abl_force_y)}
        hvelmag              = {str(hvelmag)}
        u_mean               = {str(u_mean)}
        v_mean               = {str(v_mean)}
        theta_mean           = {str(theta_mean)}
        """))

def main():
    """Run program"""
    parser = argparse.ArgumentParser(
        description="Generate a NetCDF turbulence file from U.Stuttgart data")
    parser.add_argument(
        '-i', '--input', type=str, required=True,
        help="Name of the input file")
    parser.add_argument(
        '-ts', '--t-start', type=float, required=True,
        help="Start time")
    parser.add_argument(
        '-te', '--t-end', type=float, required=True,
        help="End time")

    # args = parser.parse_args()

    abl_if = ABLInflowOutflowPrep()
    abl_if.calc_runtime_stats()

if __name__ == "__main__":
    main()
