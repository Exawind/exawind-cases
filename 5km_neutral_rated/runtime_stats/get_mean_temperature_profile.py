import netCDF4 as nc
import numpy as np

tstart = 15000
tend = 16000

boundary_planes = '../boundary_plane/post_processing/abl_statistics30000.nc'

with nc.Dataset(boundary_planes) as d:
    time = d['time'][:]
    tfilter = (time > tstart) & (time < tend)
    theta = d['mean_profiles']['theta'][tfilter,:]
    h = d['mean_profiles']['h'][:]
    avg_theta = np.average(theta,0)
    with open('avg_theta.dat','w') as f:
        f.write('{} \n'.format(avg_theta.size))
        for i,t in enumerate(avg_theta):
            f.write('{} {} \n'.format(h[i], t))

