#! /usr/bin/env python3

import csv
import sys
import math

def truncate(f, n):
    return math.floor(f * 10 ** n) / 10 ** n

def linear_interpolation(param, data):
    # Sort the data by the first column
    data.sort(key=lambda row: row[0])

    # Find the two closest points
    for i in range(len(data) - 1):
        if data[i][0] <= param <= data[i + 1][0]:
           s1, r1, p1 = data[i]
           s2, r2, p2 = data[i + 1]
           break

    # Perform linear interpolation
    interpolated_rpm = r1 + ((param - s1) / (s2 - s1)) * (r2 - r1)
    interpolated_pitch = p1 + ((param - s1) / (s2 - s1)) * (p2 - p1)

    return interpolated_rpm, interpolated_pitch

def calc_timesteps(rpm,prec_len):
    revps = rpm / 60.0
    degps = revps * 360.0
    radps = revps * 2.0 * math.pi

    cfd_dt = 0.25/degps
    # ratio of 100 matches tests by neil for the 10.59 m/s case
    # using 120 just to be safe for higher wind speeds
    ratio = int(3*math.ceil(degps) - 30)
    openfast_dt = cfd_dt / ratio

    prec_revs = int(math.floor(prec_len * revps))
    prec_chkp_length = prec_revs / revps
    
    prec_chkp_cfd_n = int(prec_chkp_length / cfd_dt)
    prec_chkp_of_n = int(prec_chkp_length / openfast_dt)

    precursor_rad = prec_chkp_length * radps
    az_blend_mean = precursor_rad + 3.0 * 2.0 * math.pi

    return truncate(cfd_dt,15), truncate(openfast_dt,15), truncate(prec_chkp_length,15), truncate(az_blend_mean,15)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("This script requires a wind speed value and precursor length value as input.")
        exit(1)
    else:
       wind_speed = float(sys.argv[1])
       precursor_length = float(sys.argv[2])
       file_name = "nrel5mw_params.csv"
       data = []
       with open(file_name, 'r') as f:
         reader = csv.reader(f)
         next(reader) # skip the header row
         for row in reader:
           speed, rpm, pitch = map(float, row)
           data.append((speed, rpm, pitch))
       designRPM, designPitch = linear_interpolation(wind_speed, data)
       cfdDt, openfastDt, precLen, azBlend = calc_timesteps(designRPM, precursor_length)
       ratio = cfdDt/openfastDt
       int_ratio = int(ratio)
       assert ratio >= float(int_ratio)
       assert int(ratio) == int_ratio    
    print(designRPM, designPitch, f"{cfdDt:.15f}", f"{openfastDt:.15f}", f"{azBlend:.15f}", f"{precLen:.15f}" , cfdDt/openfastDt, int(precLen/openfastDt))

