# coding: utf-8
import numpy as np
import pandas as pd
import yaml, sys, shutil, subprocess
from pathlib import Path

def get_rpm_pitch(wspd):
    """Get rpm and pitch for a given wind speed"""

    control_traj = pd.read_csv('ControlTraj.csv')
    rpm = np.interp(wspd, control_traj['WindVxi'], control_traj['RotSpeed'])
    pitch = np.interp(wspd, control_traj['WindVxi'], control_traj['BldPitch1'])
    return rpm, pitch

def gen_case(template_dir, case_data, case_dir=None):
    """Generate a set of Exawind cases to perform power curve

    Inputs:
       template_dir: Directory containing templates. Expected to be of the form
                     fsi_run
                        - Nalu-wind yaml file
                        - amr-wind input file
                        - static_box.txt
                        - exawind yaml file
                     openfast_run
                        - Main fst input file
                        - ElastoDyn input file
                        - inp.yaml driver input file
                        -
       case_data: Dictionary containing case data
                  {'wspd': BLAH, 'pitch': BLAH,
                   'rpm': BLAH,
                   'az_blend_mean': BLAH,
                   'az_blend_delta': BLAH }
                  Any other dictionary items will be ignored
       case_dir: Name of directory to which the new files will be written

    Outputs:
       None: Files written to directory 'case_dir'
    """

    if ( not Path(template_dir).exists() ):
        print("Template directory ", template, " doesn't exist. Please check your inputs")
        sys.exit()

    wspd = case_data['wspd']
    period_rot = 60.0/case_data['rpm']
    dt_driver = period_rot/1440.0
    dt_openfast = dt_driver/4.0

    if (case_dir is None):
        case_dir = 'wind_speed_{:04.2f}'.format(wspd)

    nalu_inp_file = Path(template_dir+'/fsi_run/nrel5mw-nalu-02.yaml')
    print(nalu_inp_file)
    with open(nalu_inp_file, 'r') as f:
        nif = yaml.load(f, Loader=yaml.UnsafeLoader)
        nif['realms'][0]['initial_conditions'][0]['value']['velocity'] = [case_data['wspd'], 0.0, 0.0]
        nif['realms'][0]['openfast_fsi']['t_start'] = 18 * period_rot
        nif['realms'][0]['openfast_fsi']['t_max'] = 100.0 * period_rot
        nif['realms'][0]['openfast_fsi']['dt_FAST'] = dt_openfast
        nif['realms'][0]['openfast_fsi']['Turbine0']['vel_mean'] = wspd
        nif['realms'][0]['openfast_fsi']['Turbine0']['az_blend_mean'] = case_data['az_blend_mean']
        nif['realms'][0]['openfast_fsi']['Turbine0']['az_blend_delta'] = case_data['az_blend_delta']
        nif['realms'][0]['restart']['restart_time'] = 8 * period_rot
        nif['Time_Integrators'][0]['StandardTimeIntegrator']['time_step'] = dt_driver

        yaml.dump(nif, open(case_dir+'/fsi_run/nrel5mw-nalu-02.yaml','w'), default_flow_style=False)

    amrwind_inp_file = Path(template_dir+'/fsi_run/nrel5mw-amr-02.inp')
    shutil.copy(amrwind_inp_file, Path(case_dir+'/fsi_run/nrel5mw-amr-02.inp'))
    subprocess.run(["sed", "-i", "s/TIME_STEP/{}/".format(dt_driver), case_dir+'/fsi_run/nrel5mw-amr-02.inp' ])
    subprocess.run(["sed", "-i", "s/WIND_SPEED/{}/".format(case_data['wspd']), case_dir+'/fsi_run/nrel5mw-amr-02.inp' ])

    exawind_inp_file = Path((template_dir+'/fsi_run/nrel5mw-02.yaml'))
    shutil.copy(exawind_inp_file, Path(case_dir+'/fsi_run/nrel5mw-02.yaml'))

if __name__=="__main__":

    windspeeds = np.array([5.0, 6.0, 7.0, 8.0, 9.0,
                           10.0, 10.59, 12.0, 14.0,
                           17.0, 20.0, 23.0, 25.0])
    rpm, pitch = get_rpm_pitch(windspeeds)

    cases = [ { 'wspd': float(w), 'rpm': float(r), 'pitch': float(p), 'az_blend_mean': 72.25663103256524, 'az_blend_delta': 3.141592653589793} for w,r,p in zip(windspeeds, rpm, pitch)]

    for c in cases:
        gen_case('template', c)
